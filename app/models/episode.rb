class Episode < ActiveRecord::Base
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks


  has_one :rating, as: :rated
  has_many :translations, :dependent => :destroy
  belongs_to :show
  belongs_to :season

  before_destroy :destroy_rating

  has_attached_file :screenshot,:styles => { :thumb => "400x225#" }, convert_options: { all: '-quality 75 -strip' }

  do_not_validate_attachment_file_type :screenshot

  scope :for_date, -> (date) {
    joins(:season, :show)
        .where("episodes.first_aired > ? AND episodes.first_aired < ? AND NOT (seasons.aired_episodes = seasons.episode_count AND shows.status LIKE 'ended')",
                                date.yesterday.beginning_of_day, date.yesterday.end_of_day)
        .order("episodes.first_aired")
  }

  scope :prev, -> {
    where(:number => number - 1)
  }

  scope :next, -> {
    where(:number => number + 1)
  }

  def prev
    self.class.where(show: show, season: season, :number => number - 1).take
  end

  def next
    self.class.where(show: show, season: season, :number => number + 1).take
  end

  def translations_list
    ids = []
    translations.each do |t|
      ids << t.id unless t.nil?
    end
    ids
  end

  def translators_list
    ids = []
    translations.each do |t|
      ids << t.translator.id unless t.translator.nil?
    end
    ids.sort!
  end

  def sync_by_tmdb
    tmdb = Tmdb.new

    _tmdb_data  = self.show.tmdb_data
    tmdb_id     = _tmdb_data['id']
    return false unless !id.nil? || tmdb_id

    self.tmdb_data       = tmdb.episode(tmdb_id, self.season.number, self.number)
    self.tmdb_images     = tmdb.season_images(tmdb_id, self.season.number, self.number)

    self.title_ru        = self.tmdb_data['name']                    if self.tmdb_data['name'].present?
    self.description_ru  = self.tmdb_data['overview']                if self.tmdb_data['overview'].present?
    self.air_date        = DateTime.parse self.tmdb_data['air_date'] if self.tmdb_data['air_date'].present?

    self.save
    self
  end

  def sync_images_by_tmdb
    tmdb = Tmdb.new

    _tmdb_data   = self.tmdb_data
    _tmdb_images = self.tmdb_images
    self.sync_season_by_tmdb if _tmdb_data.blank? || _tmdb_images.blank?

    if _tmdb_data['still_path'].blank?
      if _tmdb_images['stills'].present?
        screenshot_full_src = tmdb.img_fullpath _tmdb_images['stills'].first['file_path']
        self.screenshot     = URI.parse(screenshot_full_src)
      end
    else
      screenshot_full_src   = tmdb.img_fullpath _tmdb_data['still_path']
      self.screenshot       = URI.parse(screenshot_full_src)
    end

    self.save
    self
  end

  def sync_translation_from_tvdb
    tvdb = Tvdb.new

    translation = tvdb.episode_translation self['ids']["tvdb"]

    unless translation.nil?
      self.title_ru       = translation[:title_ru]       if translation[:title_ru].present?
      self.description_ru = translation[:description_ru] if translation[:description_ru].present?
      self.abs_name       = "#{translation[:season]}-#{translation[:episode]}" if translation[:episode] > 0
      self.number_abs     = translation[:episode] if translation[:episode] > 0
    end

    self.save
    self
  end


  private

  def destroy_rating
    Rating.delete_all rated: id
  end
end
