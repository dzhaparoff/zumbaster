class Season < ActiveRecord::Base
  has_one :rating, as: :rated
  belongs_to :show
  has_many :episodes, :dependent => :destroy

  class << self
    def columns_list
      self.column_names
    end
    alias_method :fields, :columns_list
  end

  has_attached_file :poster, :styles => { :medium => "600x900>", :thumb => "300x450>" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :thumb, :styles => { :medium => "500x281#", :thumb => "250x140#" },  convert_options: { all: '-quality 75 -strip' }

  do_not_validate_attachment_file_type :poster, :thumb

  default_scope do
    order(:number)
  end

  scope :present, -> { where("aired_episodes > 0 AND number > 0") }


  def sync_by_trakt

  end

  def sync_by_tmdb
    tmdb = Tmdb.new

    _tmdb_data = self.show.tmdb_data
    tmdb_id = _tmdb_data['id']
    return false unless !id.nil? || tmdb_id

    self.tmdb_data   = tmdb.season(tmdb_id, self.number)
    self.tmdb_images = tmdb.season_images(tmdb_id, self.number)

    self.title_ru        = self.tmdb_data['name']                    if self.tmdb_data['name'].present?
    self.description_ru  = self.tmdb_data['overview']                if self.tmdb_data['overview'].present?
    self.first_aired     = DateTime.parse self.tmdb_data['air_date'] if self.tmdb_data['air_date'].present?

    self.save
    self
  end

  def sync_images_by_tmdb
    tmdb = Tmdb.new

    _tmdb_data   = self.tmdb_data
    _tmdb_images = self.tmdb_images
    self.sync_season_by_tmdb if _tmdb_data.blank? || _tmdb_images.blank?

    if _tmdb_data['poster_path'].blank?
      if _tmdb_images['posters'].present?
        poster_full_src = tmdb.img_fullpath _tmdb_images['posters'].first['file_path']
        self.poster = URI.parse(poster_full_src)
      end
    else
      poster_full_src = tmdb.img_fullpath _tmdb_data['poster_path']
      self.poster = URI.parse(poster_full_src)
    end

    self.save
  end
end
