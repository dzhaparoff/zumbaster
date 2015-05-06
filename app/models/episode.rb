class Episode < ActiveRecord::Base
  has_one :rating, as: :rated
  has_many :translations
  belongs_to :show
  belongs_to :season

  has_attached_file :screenshot, convert_options: { all: '-quality 75 -strip' }

  do_not_validate_attachment_file_type :screenshot
end
