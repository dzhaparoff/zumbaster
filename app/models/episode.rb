class Episode < ActiveRecord::Base
  has_one :rating, as: :rated
  has_many :translations, :dependent => :destroy
  belongs_to :show
  belongs_to :season

  before_destroy :destroy_rating

  has_attached_file :screenshot,:styles => { :thumb => "400x225#" }, convert_options: { all: '-quality 75 -strip' }

  do_not_validate_attachment_file_type :screenshot

  private

  def destroy_rating
    Rating.delete_all rated: id
  end
end
