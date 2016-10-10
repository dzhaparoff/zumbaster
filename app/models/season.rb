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
end
