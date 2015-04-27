class Ratings < ActiveRecord::Base
  belongs_to :rated, polymorphic: true
  has_one :imdb_rating
  has_one :kp_rating
  has_one :zb_rating
end
