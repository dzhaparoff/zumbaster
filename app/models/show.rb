class Show < ActiveRecord::Base
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks

  # index_name "#{Rails.env}_shows"
  #
  # def self.reindex
  #   self.__elasticsearch__.create_index! force: true
  #   self.__elasticsearch__.refresh_index!
  #   self.import
  # end
  #
  # settings index: {
  #     number_of_shards: 1,
  #     number_of_replicas: 0,
  #     analysis: {
  #         analyzer: {
  #             show_analyzer: {
  #                 tokenizer: "standard",
  #                 filter: ["standard", "lowercase", "ru_snowball", "en_snowball"]
  #             }
  #         },
  #         filter: {
  #             ru_snowball: {
  #                 type: "snowball",
  #                 language: "Russian"
  #             },
  #             en_snowball: {
  #                 type: "snowball",
  #                 language: "English"
  #             },
  #         }
  #     }
  # } do
  #   mappings dynamic: 'false' do
  #     indexes :id,             type: 'integer'
  #     indexes :title_ru,       analyzer: 'show_analyzer', type: "text"
  #     indexes :title_en,       analyzer: 'show_analyzer', type: "text"
  #     indexes :description_ru, analyzer: 'show_analyzer', type: "text"
  #     indexes :description_en, analyzer: 'show_analyzer', type: "text"
  #     indexes :slogan_ru,      analyzer: 'show_analyzer', type: "text"
  #     indexes :slogan_en,      analyzer: 'show_analyzer', type: "text"
  #     indexes :network,        analyzer: 'show_analyzer', type: "text"
  #     indexes :country,        analyzer: 'show_analyzer', type: "text"
  #   end
  # end
  #
  # def as_indexed_json(options={})
  #   self.as_json(
  #       only: [:id,
  #              :title_ru,
  #              :title_en,
  #              :description_ru,
  #              :description_en,
  #              :slogan_ru,
  #              :slogan_en,
  #              :network,
  #              :country]
  #   )
  # end


  has_and_belongs_to_many :genres, :join_table => :genres_shows
  has_many :casts
  has_many :crews
  has_one :rating, as: :rated
  has_many :seasons, :dependent => :destroy
  has_many :episodes, :dependent => :destroy

  after_initialize :init

  has_attached_file :poster, :styles => { :medium => "600x900>", :thumb => "300x450>" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :poster_ru, :styles => { :medium => "600x900>", :thumb => "300x450>" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :fanart, :styles => { :medium => "1280x720>", :thumb => "853x480>" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :logo, :styles => { :medium => "400x155", :thumb => "200x75#" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :clearart, :styles => { :medium => "500x250#", :thumb => "250x125#" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :banner, :styles => { :medium => "480x70#" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :thumb, :styles => { :medium => "500x281#", :thumb => "250x140#" }, convert_options: { all: '-quality 75 -strip' }

  do_not_validate_attachment_file_type :fanart, :poster, :logo, :clearart, :banner, :thumb

  default_scope do
    where.not(updated: nil)
  end

  scope :waiting_fot_publish, -> {
    unscoped.where(updated: nil)
  }

  scope :waiting_for_update, -> (date) {
    joins(:seasons, :episodes)
        .where("episodes.first_aired > ? AND episodes.first_aired < ? AND NOT (seasons.aired_episodes = seasons.episode_count AND shows.status LIKE 'ended')",
               date.yesterday.beginning_of_day, date.yesterday.end_of_day)
        .select("DISTINCT ON (shows.id) shows.*")
  }

  class << self
    def existed_ids
      shows = unscoped.select :ids

      kp, imdb, tvrage, myshow = [],[],[],[]

      shows.each do |s|
        kp << s.ids['kp']
        imdb << s.ids['imdb']
        tvrage << s.ids['tvrage']
        myshow << s.ids['myshow']
      end

      { kp: kp, imdb: imdb, tvrage: tvrage, myshow: myshow }
    end


    def columns_list
       self.column_names
    end
    alias_method :fields, :columns_list

    def search_by_name name
      myshows = Myshows.new
      founded = myshows.find_show(name).map do |e, k|
        k["existed"] = self.where("(ids->>'myshow')::integer = ?", k["id"]).first
        k["existed_seasons"] = k["existed"].seasons  unless k["existed"].nil?
        k
      end
      founded.sort! do |e| e["existed"].nil? ? 1 : -1 end
    end
  end

  def sync_ids
    trakt = Trakt.new
    show = self

    ids = show.ids

    if ids['imdb'].blank? || ids['imdb'] == 0
      return show
    end

    imdb = imdb_to_trakt_id(show.ids['imdb'])
    trakt_show = trakt.show(imdb)

    return false if trakt_show.nil?

    show.ids = ids.merge trakt_show['ids']
    show.save
    show
  end

  def sync_with_trakt
    trakt = Trakt.new

    show = self
    ids = show.ids

    if ids['imdb'].blank? || ids['imdb'] == 0
      return show
    end

    imdb       = imdb_to_trakt_id(show.ids['imdb'])
    trakt_show = trakt.show(imdb)

    return false if trakt_show.nil?

    ids.merge! trakt_show['ids']
    show.trakt_data = trakt_show

    show.save
    show
  end


  def sync_with_tmdb
    tmdb = Tmdb.new
    show = self

    if show.ids['tmdb'].blank?
      return show
    end

    tmdb_show        = tmdb.show show.ids['tmdb']
    show.tmdb_data   = tmdb_show

    tmdb_images      = tmdb.show_images show.ids['tmdb']
    show.tmdb_images = tmdb_images

    show.save
    show
  end

  def sync_meta
    show = self.sync_with_trakt

    trakt_show = show.trakt_data

    show.slug_en        = trakt_show['ids']['slug']
    show.title_en       = trakt_show['title']
    show.description_en = trakt_show['overview']
    show.first_aired    = DateTime.parse trakt_show['first_aired']
    show.airs           = trakt_show['airs']
    show.certification  = trakt_show['certification']
    show.network        = trakt_show['network']
    show.country        = trakt_show['country']
    show.homepage       = trakt_show['homepage']
    show.status         = trakt_show['status']
    show.aired_episodes = trakt_show['aired_episodes']
    show.ids            = ids
    show.trakt_data     = trakt_show

    trakt_show['genres'].each do |genre|
      g = Genre.find_by_slug_en genre
      show.genres << g unless g.nil?
    end unless show.genres.count > 0

    show.save

    show
  end

  def sync_with_fanart
    fanart = Fanart.new
    show = self

    if show.ids['tvdb'].blank?
      return show
    end

    fanart_show        = fanart.images show.ids['tvdb']
    show.fanart_images = fanart_show

    show.save
    show
  end

  def sync_translate
    show = self

    myshow = Myshows.new
    trakt  = Trakt.new

    unless show.description_ru.nil?
      return show
    end

    imdb = imdb_to_trakt_id(show.ids['imdb'])
    trakt_show_translation = trakt.show_translations imdb
    myshow = myshow.get_show show.ids['myshow']
    myshow_translation = myshow['description']

    if trakt_show_translation.nil? || trakt_show_translation[0].nil?
      show.description_ru = "#{myshow_translation}"
    else
      show.description_ru = "#{myshow_translation} <p>#{trakt_show_translation[0]['overview']}</p>"
    end

    show.save
    show
  end

  def sync_pics
    show = self

    trakt  = Trakt.new
    tmdb   = Tmdb.new
    fanart = Fanart.new

    if show.ids['tmdb'].blank?
      return show
    end

    if show.tmdb_data.blank?
      _tmdb_data   = show.tmdb_data   = tmdb.show show.ids['tmdb']
      _tmdb_images = show.tmdb_images = tmdb.show_images show.ids['tmdb']
    else
      _tmdb_data   = show.tmdb_data
      _tmdb_images = show.tmdb_images
    end

    if show.fanart_images.blank?
      _fanart_images = show.fanart_images = fanart.images show.ids['tvdb']
    else
      _fanart_images = show.fanart_images
    end

    if _tmdb_data['poster_path'].blank?
      if _tmdb_images['posters'].present?
        poster_full_src = tmdb.img_fullpath _tmdb_images['posters'].first['file_path']
        show.poster = URI.parse(poster_full_src)
      end
    else
      poster_full_src = tmdb.img_fullpath _tmdb_data['poster_path']
      show.poster = URI.parse(poster_full_src)
    end

    if _tmdb_data['backdrop_path'].blank?
      if _tmdb_images['backdrops'].present?
        fanart_full_src = tmdb.img_fullpath _tmdb_images['backdrops'].first
        show.fanart = URI.parse(fanart_full_src)
      end
    else
      fanart_full_src = tmdb.img_fullpath _tmdb_data['backdrop_path']
      show.fanart = URI.parse(fanart_full_src)
    end

    if _fanart_images['tvbanner'].present?
      show.banner = URI.parse(_fanart_images['tvbanner'].first['url']) if _fanart_images['tvbanner'].first.present?
    end

    if !show.poster_ru.exists? && show.ids['kp'].present?
      show.poster_ru = URI.parse("http://st.kinopoisk.ru/images/film_big/#{show.ids['kp']}.jpg")
    end

    show.save
    show
  end

  def sync_rating
    show = self

    if show.ids['kp'].blank?
      return show
    end

    kinopoisk = Kinopoisk.new

    kp = show.ids['kp']
    rating = kinopoisk.rating(kp)

    new_rating = Rating.first_or_create(rated: show)

    unless new_rating.nil?
      new_rating_imdb = ImdbRating.find_or_create_by(
        rating: new_rating,
        value: rating[:imdb],
        count: rating[:imdb_num_vote]
      )
      new_rating_imdb.save

      new_rating_kp = KpRating.find_or_create_by(
        rating: new_rating,
        value: rating[:kp],
        count: rating[:kp_num_vote]
      )
      new_rating_kp.save
    end

    new_rating.save
    show
  end

  def seasons_trakt
    show = self.sync_with_trakt
    trakt = Trakt.new

    ids = show.ids

    if ids['imdb'].blank? || ids['imdb'] == 0
      return nil
    end

    imdb = imdb_to_trakt_id(show.ids['imdb'])
    return trakt.show_seasons imdb
  end

  def seasons_tmdb
    show = self.sync_with_tmdb
    if show.tmdb_data.present?
      return show.tmdb_data['seasons']
    else
      return nil
    end
  end

  def activate
    show = self

    if show.ids['imdb'].blank?
      return show
    end

    trakt  = Trakt.new

    imdb = imdb_to_trakt_id(show.ids['imdb'])
    trakt_show = trakt.show(imdb)

    return show if trakt_show.nil?

    show.updated = DateTime.parse trakt_show['updated_at']
    show.save

    show
  end

  def sync_videos
    show = self

    Translator.sync

    if show.ids['kp'].blank?
      return show
    end

    kp = show.ids['kp']

    moonwalkApi = Moonwalk.new

    moonwalk = moonwalkApi.show kp

    moonwalk.each do |m|
      translator_id = m['translator_id']
      moonwalk_episodes = moonwalkApi.get_playlist_url_parallel kp, translator_id
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

    show
  end

  def sync_ru_names
    show = self

    if show.ids['kp'].blank?
      return show
    end

    kp = show.ids['kp']
    kinopoisk = Kinopoisk.new

    kp_episode_names = kinopoisk.episode_names kp
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

    show
  end

  attr_reader :img

  private

  def imdb_to_trakt_id imdb
    if imdb.is_a?(String) && imdb[0] == 't'
      return imdb
    else
      return "tt%07d" % imdb.to_i
    end
  end

  def init
    @img = poster.url(:thumb)
  end
end
