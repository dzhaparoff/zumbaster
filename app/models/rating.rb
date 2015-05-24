class Rating < ActiveRecord::Base
  belongs_to :rated, polymorphic: true
  has_one :imdb_rating, :dependent => :destroy
  has_one :kp_rating, :dependent => :destroy
  has_one :zb_rating, :dependent => :destroy
end
