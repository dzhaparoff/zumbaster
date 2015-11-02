class ShowsController < ApplicationController
  before_action :parse_params

  def detail
    @show = Show.find_by_slug_ru @show_slug
    @genres = @show.genres
  end

  def season
    @show = Show.find_by_slug_ru @show_slug
    @season = @show.seasons.where(number: @season_number).take
  end

  def episode
    @show = Show.find_by_slug_ru @show_slug
    @season = @show.seasons.where(number: @season_number).take
    @episode = @season.episodes.where(number: @episode_number).take

    # render_404 if @episode.translations.count < 1
  end

  private

  def parse_params
    @show_slug = params[:show_slug]
    @season_number = params[:season_number].to_i
    @episode_number = params[:episode_number].to_i
  end
end
