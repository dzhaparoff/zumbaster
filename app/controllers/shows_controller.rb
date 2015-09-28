class ShowsController < ApplicationController
  before_action :parse_params

  def detail
    @show = Show.find_by_slug_ru @show_slug
    @genres = @show.genres

    set_meta_tags title: @show.title_ru
  end

  def season
    @show = Show.find_by_slug_ru @show_slug

    @season = @show.seasons.where(number: @season_number).take

    set_meta_tags title: "#{@show.title_ru}, смотреть #{@season.number} сезон онлайн"
  end

  def episode
    @show = Show.find_by_slug_ru @show_slug

    @season = @show.seasons.where(number: @season_number).take
    @episode = @season.episodes.where(number: @episode_number).take

    set_meta_tags title: "#{@show.title_ru} - #{@episode.title_ru}, #{@season.number} сезон #{@episode.number} эпизод смотреть онлайн"
  end

  private

  def parse_params
    @show_slug = params[:show_slug]
    @season_number = params[:season_number].to_i
    @episode_number = params[:episode_number].to_i
  end
end
