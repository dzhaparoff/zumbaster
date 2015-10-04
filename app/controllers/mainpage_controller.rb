class MainpageController < ApplicationController
  def index
    @new_shows = Show.order(:first_aired => :desc).take 6
    @new_episodes = Episode.includes(:translations).order(:first_aired => :desc).where.not(translations: {id: nil}).take 12

    best_kp_ratings = Rating.joins(:kp_rating).order("kp_ratings.value DESC").where("value > 8").select(:id).take 15
    best_imdb_ratings = Rating.joins(:imdb_rating).order("imdb_ratings.value DESC").where("value > 8").select(:id).take 15

    top = Show.joins(:rating)
              .where("ratings.id in (?) and ratings.id in (?) ", best_kp_ratings, best_imdb_ratings)
              .sort_by do |s|
                - s.rating.imdb_rating.value * s.rating.kp_rating.value / 2
              end
    @top_ten = top[0...10]

    random_seed = rand(Show.count)
    @random_show = Show.offset(random_seed).take

    @popular_shows = Show.take(12)
  end

  # def sitemap
  #   path = Rails.root.join("public", "sitemaps", "sitemap.xml")
  #   if File.exists?(path)
  #     render xml: open(path).read
  #   else
  #     render text: "Sitemap not found.", status: :not_found
  #   end
  # end
  #
  # def robots
  # end

  private

end
