class Admin::Api::ApiController < Admin::AdminController

  def initialize
    @myshow = Myshows.new
    @trakt = Trakt.new
    @moonwalk = Moonwalk.new
    @kinopoisk = Kinopoisk.new
  end

  def check
    render json: @trakt.genres
  end

  def sync_genres
    genres = @trakt.genres
    genres.each do |genre|
      if Genre.find_by_slug_en(genre['slug']).nil?
        new_genre = Genre.new do |g|
          g.name_en = genre['name']
          g.slug_en = genre['slug']
        end
        new_genre.save
      end
    end

    render json: genres
  end

  def sync_translators
    translators = @moonwalk.translators

    translators.each do |translator|
      if Translator.find_by_ex_id(translator['id']).nil?
        new_translator = Translator.new do |t|
          t.ex_id = translator['id']
          t.name = translator['name']
        end
        new_translator.save
      end
    end

    render json: translators
  end

  def sync_shows
    shows = @myshow.get_top_shows

    existing_ids = existing_show_ids :myshow

    shows = shows[99..500].map do |show|
      sleep 0.01
      show.merge! @myshow.get_show show['id'] unless existing_ids.include? show['id']
    end

    shows.compact!

    shows.each do |show|
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
          s.year = show['year']
          s.ids = ids
          s.runtime = show['runtime']
          s.status = show['status']
        end
        new_show.save
    end

    render json: true
  end

  def sync_shows_trakt
    shows = Show.all

    shows.each do |show|
      next unless show.ids['imdb'].to_i > 0
      next unless show.updated.nil?

      imdb = imdb_to_trakt_id show.ids['imdb']
      trakt_show = @trakt.show imdb

      next if trakt_show.nil?

      show.slug_en = trakt_show['ids']['slug']
      show.title_en = trakt_show['title']
      show.description_en = trakt_show['overview']
      show.first_aired = DateTime.parse trakt_show['first_aired']
      show.updated = DateTime.parse trakt_show['updated_at']
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
      end
      show.save
      sleep 0.02
    end

    render json: true
  end

  def sync_shows_pics
    shows = Show.all

    shows.each do |show|
      next unless show.ids['imdb'].to_i > 0
      next if show.poster.exists? && show.fanart.exists? && show.logo.exists? && show.clearart.exists? && show.banner.exists? && show.thumb.exists?

      imdb = imdb_to_trakt_id show.ids['imdb']
      trakt_show = @trakt.show imdb

      next if trakt_show.nil?

      show.poster = URI.parse(trakt_show['images']['poster']['full']) unless trakt_show['images']['poster']['full'].nil?
      show.fanart = URI.parse(trakt_show['images']['fanart']['full']) unless trakt_show['images']['fanart']['full'].nil?
      show.logo = URI.parse(trakt_show['images']['logo']['full']) unless trakt_show['images']['logo']['full'].nil?
      show.clearart = URI.parse(trakt_show['images']['clearart']['full']) unless trakt_show['images']['clearart']['full'].nil?
      show.banner = URI.parse(trakt_show['images']['banner']['full']) unless trakt_show['images']['banner']['full'].nil?
      show.thumb = URI.parse(trakt_show['images']['thumb']['full']) unless trakt_show['images']['thumb']['full'].nil?

      show.save

      sleep 0.02
    end

    render json: true
  end

  def sync_poster_ru
    shows = Show.all

    shows.each do |show|
      next unless show.ids['kp'].to_i > 0
      next if show.poster_ru.exists?
      kp = show.ids['kp']
      show.poster_ru = URI.parse("http://st.kinopoisk.ru/images/film_big/#{kp}.jpg")
      show.save

      sleep 0.01
    end
    render json: true
  end

  def sync_shows_translate
    shows = Show.all

    shows.each do |show|
      next unless show.description_ru.nil?
      next unless show.ids['imdb'].to_i > 0

      imdb = imdb_to_trakt_id show.ids['imdb']
      trakt_show_translation = @trakt.show_translations imdb

      next if trakt_show_translation.nil?
      next if trakt_show_translation[0].nil?

      show.description_ru = trakt_show_translation[0]['overview']
      show.save

      sleep 0.02
    end

    render json: true

  end

  private

  def existing_show_ids which_id
    shows = Show.select :ids

    kp, imdb, tvrage, myshow = [],[],[],[]

    shows.each do |s|
      kp << s.ids['kp']
      imdb << s.ids['imdb']
      tvrage << s.ids['tvrage']
      myshow << s.ids['myshow']
    end

    case which_id
      when :kp
        return kp
      when :imdb
        return imdb
      when :tvrage
        return tvrage
      when :myshow
        return myshow
      else
        return {kp: kp, imdb: imdb, tvrage: tvrage, myshow: myshow}
    end

  end

  def imdb_to_trakt_id imdb
    "tt%07d" % imdb.to_i
  end

end