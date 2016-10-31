class UpdateSeasonJob < ActiveJob::Base
  queue_as :default

  def perform(*args)

    date = DateTime.now

    7.times do |increment|

      date = date + increment.day

      episodes = Episode.for_date date

      @trakt = Trakt.new
      @tvdb = Tvdb.new
      @moonwalk = Moonwalk.new
      @force_reload = false

      episodes.each do |episode_for_update|
        show = episode_for_update.show
        season = episode_for_update.season

        imdb          = "tt%07d" % show.ids['imdb'].to_i
        trakt_seasons = show.seasons_trakt

        sleep 0.5

        next if trakt_seasons.nil?

        trakt_seasons.each do |trakt_season|
          next if trakt_season['number'] != season.number

          season_number = "s%02d" % season.number

          season.episode_count  = trakt_season['episode_count']
          season.aired_episodes = trakt_season['aired_episodes']
          season.save

          season.sync_by_tmdb
          season.sync_images_by_tmdb

          next if trakt_season['episodes'].nil?

          trakt_season['episodes'].each do |episode|
            e = Episode.where(show: show, season: season, number: episode['number']).first_or_create
            sleep 0.25

            episode_number = "e%02d" % episode['number']
            e.ids = episode['ids']

            e.slug_ru        = "#{season_number}#{episode_number}"
            e.slug_en        = "#{season_number}#{episode_number}"

            e.title_en       = episode['title']
            e.number_abs     = episode['number_abs']
            e.description_en = episode['overview']

            e.first_aired    = DateTime.parse episode['first_aired'] unless episode['first_aired'].nil?

            e.abs_name       = "#{season['number']}-#{episode['number']}"

            e.sync_translation_from_tvdb
            e.sync_by_tmdb
            e.sync_images_by_tmdb

            e.save
          end
        end
      end
    end
  end
end
