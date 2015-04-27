class MainpageController < ApplicationController
  def index
    myshow = Myshows.new
    trakt = Trakt.new
    moonwalk = Moonwalk.new
    kinopoisk = Kinopoisk.new

    shows = myshow.get_top_shows

    first_show = shows[3]
    first_myshow = myshow.get_show(first_show['id'])

    imdb = first_myshow['imdbId'].to_int > 999999 ? "tt#{first_myshow['imdbId']}" : "tt0#{first_myshow['imdbId']}"
    kinopoisk_id = first_myshow['kinopoiskId']

    @genres = trakt.genres
    # @trakt_show = trakt.show(imdb)
    # sleep 2
    # @trakt_seasons = trakt.show_seasons(imdb)
    # @trakt_show_people = trakt.show_people(imdb)
    # @moonwalk_show = moonwalk.show(kinopoisk_id)
    # @kinopoisk = kinopoisk.rating(kinopoisk_id)
  end
end
