class Rating < ActiveRecord::Base
  belongs_to :rated, polymorphic: true, dependent: :destroy
  has_one :imdb_rating, :dependent => :destroy
  has_one :kp_rating, :dependent => :destroy
  has_one :zb_rating, :dependent => :destroy
end
