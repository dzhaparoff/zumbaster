class Shows < ActiveRecord::Base
  has_and_belongs_to_many :genres
  has_many :cast_people
  has_many :crew_people
  has_one :rating
  has_many :seasons
  has_many :episodes

  attr_accessible :fanart, :poster, :logo, :clearart, :banner, :thumb
  has_attached_file :poster, :styles => { :medium => "600x900>", :thumb => "300x450>" }
  has_attached_file :fanart, :styles => { :medium => "1280x720>", :thumb => "853x480>" }
  has_attached_file :logo, :styles => { :medium => "400x155", :thumb => "200x75#" }
  has_attached_file :clearart, :styles => { :medium => "500x250#", :thumb => "250x125#" }
  has_attached_file :banner, :styles => { :medium => "480x70#" }
  has_attached_file :thumb, :styles => { :medium => "500x281#", :thumb => "250x140#" }

  do_not_validate_attachment_file_type :fanart, :poster, :logo, :clearart, :banner, :thumb
end
