class Season < ActiveRecord::Base
  has_one :rating, as: :rated
  belongs_to :show
  has_many :episodes, :dependent => :destroy

  has_attached_file :poster, :styles => { :medium => "600x900>", :thumb => "300x450>" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :thumb, :styles => { :medium => "500x281#", :thumb => "250x140#" },  convert_options: { all: '-quality 75 -strip' }

  do_not_validate_attachment_file_type :poster, :thumb
end
