class Genre < ActiveRecord::Base
  has_and_belongs_to_many :shows, :join_table => :genres_shows
end
