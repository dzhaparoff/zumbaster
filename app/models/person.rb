class Person < ActiveRecord::Base
  has_attached_file :headshot, :styles => { :medium => "600x900", :thumb => "300x450", :cropped_thumb => "150x150#" }, convert_options: { all: '-quality 75 -strip' }
  do_not_validate_attachment_file_type :headshot
end
