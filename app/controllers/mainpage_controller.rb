class MainpageController < ApplicationController
  def index
    @shows = Show.find_each

    #@shows = []

    # shows.each do |s|
    #   show = {}
    #   show[:title] = s.title_ru
    #   show[:description] = s.description_ru
    #   show[:poster] = s.poster.url(:original)
    #   seasons = []
    #   s.seasons.find_each do |s|
    #     season = []
    #     season[:number] = s.number
    #     seasons << season
    #   end
    #   @shows << show
    # end

  end

  private

end
