class Admin::Api::ShowsController < Admin::Api::ApiController
  def index
    render json: Show.order('id asc').all
  end

  def new
    render json: {}
  end

  def create
    show = model_params
    show.merge! @myshow.get_show model_params[:id]

    new_show = Show.new do |s|
      ids = {
          kp: show['kinopoiskId'],
          imdb: show['imdbId'],
          tvrage: show['tvrageId'],
          myshow: show['id']
      }
      s.slug_ru = show['ruTitle'].parameterize unless show['ruTitle'].nil?
      s.slug_en = show['title'].parameterize unless show['title'].nil?
      s.title_ru = show['ruTitle']
      s.title_en = show['title']
      s.description_ru = show['description']
      s.year = show['year']
      s.ids = ids
      s.runtime = show['runtime']
      s.status = show['status']
    end
    new_show.save

    render json: new_show
  end

  def show
    render json: Show.unscoped.find(params[:id])
  end

  def edit

  end

  def update
    show = Show.unscoped.find(params[:id])
    unless params[:ids].nil? && params[:ids].size > 0
      show.ids = params[:ids]
      show.save
    end
    render json: show.update(model_params)
  end

  def destroy

  end

  ### non restful

  def search_in_myshow
    shows = @myshow.find_show(params[:name])
    existing_ids = Show.existed_ids
    shows.each do |_, show|
      show['exist'] = true if existing_ids[:myshow].include? show['id']
    end
    render json: shows
  end

  def sync_with_trakt
    show = Show.unscoped.find(params[:id])

    if show.ids['imdb'].to_i == 0
      return render json: show
    end

    imdb = imdb_to_trakt_id(show.ids['imdb'])
    trakt_show = @trakt.show(imdb)

    return false if trakt_show.nil?

    show.slug_en = trakt_show['ids']['slug']
    show.title_en = trakt_show['title']
    show.description_en = trakt_show['overview']
    show.first_aired = DateTime.parse trakt_show['first_aired']
    #show.updated = DateTime.parse trakt_show['updated_at']
    show.airs = trakt_show['airs']
    show.certification = trakt_show['certification']
    show.network = trakt_show['network']
    show.country = trakt_show['country']
    show.homepage = trakt_show['homepage']
    show.status = trakt_show['status']
    show.aired_episodes = trakt_show['aired_episodes']

    trakt_show['genres'].each do |genre|
      g = Genre.find_by_slug_en genre
      show.genres << g unless g.nil?
    end unless show.genres.count > 0

    show.save

    sleep 0.5

    render json: show
  end

  def sync_translate
    show = Show.unscoped.find(params[:id])

    unless show.description_ru.nil? || show.ids['imdb'].to_i > 0
      return render json: show
    end

    imdb = imdb_to_trakt_id show.ids['imdb']
    trakt_show_translation = @trakt.show_translations imdb
    myshow = @myshow.get_show show.ids['myshow']
    myshow_translation = myshow['description']

    if trakt_show_translation.nil? || trakt_show_translation[0].nil?
      show.description_ru = "#{myshow_translation}"
    else
      show.description_ru = "#{myshow_translation} <p>#{trakt_show_translation[0]['overview']}</p>"
    end

    show.save

    sleep 0.5

    render json: show
  end

  def sync_pics
    show = Show.unscoped.find(params[:id])

    if show.ids['imdb'].to_i == 0 || show.poster.exists? || show.fanart.exists? || show.logo.exists? || show.clearart.exists? || show.banner.exists? || show.thumb.exists?
      return render json: show
    end

    imdb = imdb_to_trakt_id show.ids['imdb']
    trakt_show = @trakt.show imdb

    if trakt_show.nil?
      return render json: show
    end

    show.poster = URI.parse(trakt_show['images']['poster']['full']) unless trakt_show['images']['poster']['full'].nil?
    show.fanart = URI.parse(trakt_show['images']['fanart']['full']) unless trakt_show['images']['fanart']['full'].nil?
    show.logo = URI.parse(trakt_show['images']['logo']['full']) unless trakt_show['images']['logo']['full'].nil?
    show.clearart = URI.parse(trakt_show['images']['clearart']['full']) unless trakt_show['images']['clearart']['full'].nil?
    show.banner = URI.parse(trakt_show['images']['banner']['full']) unless trakt_show['images']['banner']['full'].nil?
    show.thumb = URI.parse(trakt_show['images']['thumb']['full']) unless trakt_show['images']['thumb']['full'].nil?

    show.save

    sleep 0.01

    render json: show
  end


  def sync_ru_pics
    show = Show.unscoped.find(params[:id])
    if show.poster_ru.exists? || show.ids['kp'].to_i == 0
      return render json: show
    end
    show.poster_ru = URI.parse("http://st.kinopoisk.ru/images/film_big/#{show.ids['kp']}.jpg")
    show.save

    sleep 0.01

    render json: show
  end

  def sync_rating
    show = Show.unscoped.find(params[:id])

    if show.ids['kp'].to_i == 0
      return render json: show
    end

    kp = show.ids['kp']
    rating = @kinopoisk.rating(kp)

    new_rating = Rating.find_or_create_by rated: show do |r|
      new_rating_imdb = ImdbRating.find_or_create_by rating: r do |r_item|
        r_item.value = rating[:imdb]
        r_item.count = rating[:imdb_num_vote]
      end
      new_rating_imdb.save

      new_rating_kp = KpRating.find_or_create_by rating: r do |r_item|
        r_item.value = rating[:kp]
        r_item.count = rating[:kp_num_vote]
      end
      new_rating_kp.save
    end
    new_rating.save

    sleep 0.01

    render json: show
  end


  def sync_people

    show = Show.unscoped.find(params[:id])

    if show.ids['kp'].to_i == 0
      return render json: show
    end

    imdb = imdb_to_trakt_id show.ids['imdb']
    people = @trakt.show_people imdb

    people['cast'].each do |c|
      person = Person.where(slug_en: c['person']['ids']['slug']).first_or_create
      cast = show.casts.where(character: c['character'], person: person, show: show).first_or_create
      person.name_en = c['person']['name']
      person.slug_en = c['person']['ids']['slug']
      person.biography_en = c['person']['biography']
      person.birthday = Date.parse c['person']['birthday'] unless c['person']['birthday'].nil?
      person.death = Date.parse c['person']['death'] unless c['person']['death'].nil?
      person.ids = c['person']['ids']
      person.headshot = c['person']['images']['headshot']['full'] unless c['person']['images']['headshot']['full'].nil? || person.headshot.exists?
      person.save
      cast.save
      show.casts << cast
    end unless people['cast'].nil?

    people['crew'].each do |key, group|
      group.each do |c|
        person = Person.where(slug_en: c['person']['ids']['slug']).first_or_create
        crew = show.crews.where(job: c['job'], person: person, show: show).first_or_create
        person.name_en = c['person']['name']
        person.slug_en = c['person']['ids']['slug']
        person.biography_en = c['person']['biography']
        person.birthday = Date.parse c['person']['birthday'] unless c['person']['birthday'].nil?
        person.death = Date.parse c['person']['death'] unless c['person']['death'].nil?
        person.ids = c['person']['ids']
        person.headshot = c['person']['images']['headshot']['full'] unless c['person']['images']['headshot']['full'].nil? || person.headshot.exists?
        person.save
        crew.job_group = key
        crew.save
        show.crews << crew
      end
    end unless people['crew'].nil?

    show.save

    render json: show

  end


  def activate
    show = Show.unscoped.find(params[:id])

    if show.ids['imdb'].to_i == 0
      return render json: show
    end

    imdb = imdb_to_trakt_id(show.ids['imdb'])
    trakt_show = @trakt.show(imdb)

    return false if trakt_show.nil?
    show.updated = DateTime.parse trakt_show['updated_at']
    show.save

    sleep 0.5

    render json: show
  end

  def sync_seasons2
    show = Show.unscoped.find(params[:id])

    if show.ids['imdb'].to_i == 0
      return render json: show
    end

    # next if show.status == 'ended' unless show.seasons.nil?

    imdb = imdb_to_trakt_id show.ids['imdb']
    trakt_seasons = @trakt.show_seasons imdb

    if trakt_seasons.nil?
      return render json: show
    end

    trakt_seasons.each do |season|
      next if season['number'] == 0

      # next if show.seasons.order(number: :asc).last.number > season['number'] && show.seasons.count > 0

      s = Season.where(show: show, number: season['number']).first_or_create

      season_number = "s%02d" % season['number']
      s.number = season['number']
      s.ids = season['ids']
      s.episode_count = season['episode_count']
      s.aired_episodes = season['aired_episodes']
      s.slug_ru = s.slug_en = "#{season_number}"
      s.description_ru = season['overview']

      s.poster = URI.parse season['images']['poster']['full'] unless season['images']['poster']['full'].nil? || s.poster.exists?
      s.thumb = URI.parse season['images']['thumb']['full'] unless season['images']['thumb']['full'].nil? || s.thumb.exists?

      s.save

      next if season['episodes'].nil?

      season['episodes'].each do |episode|
        e = Episode.where(show: show, season: s, number: episode['number']).first_or_create

        episode_number = "e%02d" % episode['number']
        e.show = show
        e.season = s
        e.number = episode['number']
        e.ids = episode['ids']
        e.slug_ru = "#{season_number}#{episode_number}"
        e.slug_en = "#{season_number}#{episode_number}"
        e.title_en = episode['title']
        e.slug_en = episode['title'].parameterize unless episode['title'].nil?
        e.number_abs = episode['number_abs']
        e.description_en = episode['overview']
        e.first_aired = DateTime.parse episode['first_aired'] unless episode['first_aired'].nil?

        screenshot_status = Faraday.new.get(episode['images']['screenshot']['full']).status unless episode['images']['screenshot']['full'].nil?

        e.screenshot = URI.parse episode['images']['screenshot']['full'] unless episode['images']['screenshot']['full'].nil? || e.screenshot.exists? || screenshot_status == 403 || screenshot_status == 404
        e.save
      end
    end

    trakt_show = @trakt.show(imdb)
    show.updated = DateTime.parse trakt_show['updated_at']
    show.save

    render json: show
  end

  def sync_seasons
    show = Show.unscoped.find params[:id]
    job = Delayed::Job.enqueue SyncAllSeasonsJob.new(show)
    render json: {
               model: show,
               job: job
           }
  end

  def sync_videos
    show = Show.unscoped.find(params[:id])

    if show.ids['kp'].to_i == 0
      return render json: show
    end

    kp = show.ids['kp']

    moonwalk = @moonwalk.show kp

    moonwalk.each do |m|
      translator_id = m['translator_id']

      moonwalk_episodes = @moonwalk.get_playlist_url_parallel kp, translator_id

      moonwalk_episodes[:playlists].each_pair do |season_number, episodes|
        season = Season.where(show: show, number: season_number).take
        episodes.each_pair do |episode_number, playlists|
          episode = Episode.where(show: show, season: season, number: episode_number).take
          translator = Translator.where(ex_id: translator_id).take
          translation = Translation.where(episode: episode, translator: translator).first_or_create
          translation.f4m = playlists['playlists']['manifest_f4m'] unless playlists['playlists'].nil? || playlists
          translation.m3u8 = playlists['playlists']['manifest_m3u8'] unless playlists['playlists'].nil? || playlists
          translation.moonwalk_token = playlists['token']
          translation.save
        end
      end
    end

    render json: show
  end

  def sync_ru_names
    show = Show.unscoped.find(params[:id])

    if show.ids['kp'].to_i == 0
      return render json: show
    end

    kp = show.ids['kp']
    kp_episode_names = @kinopoisk.episode_names kp
    show.episodes.each do |episode|
      title_en = episode.title_en
      next if title_en.nil?
      next if title_en.size < 2
      kp_episode_names.each do |key, value|
        next unless value.size > 0
        regexp = Regexp.new("#{title_en}", Regexp::IGNORECASE)
        if key.length > 1
          regexp2 = Regexp.new("#{key}", Regexp::IGNORECASE)
        else
          regexp2 = key
        end
        if key[regexp] || title_en[regexp2]
          episode.title_ru = value
          episode.title_en = key
        end
      end
      episode.save
    end

    render json: show
  end

  ### end

  private

  def model_params
    params
        .permit(
            :country,
            :slug_ru,
            :slug_en,
            :description,
            :description_ru,
            :description_en,
            :slogan_ru,
            :slogan_en,
            :ended,
            :id,
            :ids,
            :imdbId,
            :kinopoiskId,
            :rating,
            :ruTitle,
            :title,
            :runtime,
            :started,
            :status,
            :tvrageId,
            :year
        )
  end
end