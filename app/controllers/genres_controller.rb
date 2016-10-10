class GenresController < ApplicationController
  before_action :parse_params

  def detail
    @genre = Genre.where(slug_ru: @genre_slug).take
    @shows = @genre.shows
  end

  private

  def parse_params
    @genre_slug = params[:genre_slug]
  end
end
