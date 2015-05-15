class Show < ActiveRecord::Base
  has_and_belongs_to_many :genres, :join_table => :genres_shows
  has_many :casts
  has_many :crews
  has_one :rating, as: :rated
  has_many :seasons
  has_many :episodes

  has_attached_file :poster, :styles => { :medium => "600x900>", :thumb => "300x450>" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :poster_ru, :styles => { :medium => "600x900>", :thumb => "300x450>" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :fanart, :styles => { :medium => "1280x720>", :thumb => "853x480>" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :logo, :styles => { :medium => "400x155", :thumb => "200x75#" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :clearart, :styles => { :medium => "500x250#", :thumb => "250x125#" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :banner, :styles => { :medium => "480x70#" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :thumb, :styles => { :medium => "500x281#", :thumb => "250x140#" }, convert_options: { all: '-quality 75 -strip' }

  do_not_validate_attachment_file_type :fanart, :poster, :logo, :clearart, :banner, :thumb

  def self.existed_ids
    shows = select :ids

    kp, imdb, tvrage, myshow = [],[],[],[]

    shows.each do |s|
      kp << s.ids['kp']
      imdb << s.ids['imdb']
      tvrage << s.ids['tvrage']
      myshow << s.ids['myshow']
    end

    { kp: kp, imdb: imdb, tvrage: tvrage, myshow: myshow }
  end
end
