class Episode < ActiveRecord::Base
  has_one :rating, as: :rated
  has_many :translations
  belongs_to :show
  belongs_to :season

  attr_accessible :screenshot

  has_attached_file :screenshot, :styles => { :medium => "1280x720", :thumb => "853x480" }, convert_options: { all: '-quality 75 -strip' }

  do_not_validate_attachment_file_type :screenshot
end
