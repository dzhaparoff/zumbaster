class GenresController < ApplicationController
  def detail
    @genre = Genre.where(slug_ru: @genre_slug).take
  end

  private

  def parse_params
    @genre_slug = params[:genre_slug]
  end
end
