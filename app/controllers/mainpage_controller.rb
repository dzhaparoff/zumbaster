class MainpageController < ApplicationController
  def index
    @shows = Show.find_each
    @new_shows = Show.order(:first_aired => :desc).take 3
    @genres = Genre.all
  end

  private

end
