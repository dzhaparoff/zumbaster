class MainpageController < ApplicationController
  def index
    @shows = Show.find_each
    @new_shows = Show.order(:first_aired => :desc).take 6
    @new_episodes = Episode.includes(:translations).order(:first_aired => :desc).where.not(translations: {id: nil}).take 12

    best_kp_ratings = Rating.joins(:kp_rating).order("kp_ratings.value DESC").where("value > 8").select(:id).take 7
    best_imdb_ratings = Rating.joins(:imdb_rating).order("imdb_ratings.value DESC").where("value > 8").select(:id).take 6

    @top_kinopoisk = Show.joins(:rating).where("ratings.id in (?)", best_kp_ratings).all.sort_by {|s| - s.rating.kp_rating.value}
    @top_imdb = Show.joins(:rating).where("ratings.id in (?)", best_imdb_ratings).all.sort_by {|s| - s.rating.imdb_rating.value}
  end

  private

end
