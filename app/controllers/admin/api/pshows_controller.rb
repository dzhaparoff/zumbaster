class Admin::Api::PshowsController < Admin::Api::ApiController
  def index
    @items = Show.waiting_fot_publish.order('id asc').all
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

    @item = new_show
    render action: :show
  end

  def show
    @item = Show.unscoped.find(params[:id])
  rescue
    not_found
  end

  def edit

  end

  def update
    show = Show.unscoped.find(params[:id])
    if model_params[:ids].present? && model_params[:ids].size > 0
      show.update(ids: model_params[:ids])
    end
    show.update(model_params)
    @item = show
    render action: :show
  end

  def destroy
    show = Show.unscoped.find(params[:id])
    show.destroy
    render json: { deleted: true }
  end

  ### non restful

  def search_in_myshow
    shows = @myshow.find_show(params[:name])
    return render json: [] if shows.size == 0

    existing_ids = Show.existed_ids
    shows.values.each do |show|
      show['exist'] = true if existing_ids[:myshow].include? show['id'].to_i
    end
    render json: shows.values
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

    @item = show
    render action: :show, formats: :json
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

    @item = show
    render action: :show, formats: :json
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

    if show.poster_ru.exists? || show.ids['kp'].to_i == 0
      return render json: show
    end
    show.poster_ru = URI.parse("http://st.kinopoisk.ru/images/film_big/#{show.ids['kp']}.jpg")

    show.save

    sleep 0.01

    @item = show
    render action: :show, formats: :json
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

    @item = show
    render action: :show, formats: :json
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

    @item = show
    render action: :show, formats: :json
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

    @item = show
    render action: :show, formats: :json
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
        episodes.each_pair do |episode_number, playlists|
          episode = Episode.where(show: show, abs_name: "#{season_number.to_i}-#{episode_number.to_i}").take
          translator = Translator.where(ex_id: translator_id).take
          translation = Translation.where(episode: episode, translator: translator).first_or_create
          translation.moonwalk_token = playlists['token'] unless translation.moonwalk_token == 'temp_token'
          translation.save
        end
      end
    end

    @item = show
    render action: :show, formats: :json
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

    @item = show
    render action: :show, formats: :json
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
