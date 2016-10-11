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

        imdb = "tt%07d" % show.ids['imdb'].to_i
        trakt_seasons = @trakt.show_seasons imdb
        sleep 0.5
        next if trakt_seasons.nil?

        trakt_seasons.each do |trakt_season|
          next if trakt_season['number'] != season.number

          season_number = "s%02d" % season.number

          season.episode_count = trakt_season['episode_count']
          season.aired_episodes = trakt_season['aired_episodes']
          season.description_ru = trakt_season['overview'] unless season.description_ru.nil?

          begin
            poster_full_src = trakt_season['images']['poster']['full']
            if poster_full_src.present?
              poster_full_src = poster_full_src.sub('medium', 'original')
              season.poster = URI.parse(poster_full_src)
            end
          rescue
          end

          begin
            thumb_full_src = trakt_season['images']['thumb']['full']
            if thumb_full_src.present?
              thumb_full_src = thumb_full_src.sub('medium', 'original')
              season.thumb = URI.parse(thumb_full_src)
            end
          rescue
          end

          sleep 0.5
          season.save

          next if trakt_season['episodes'].nil?

          trakt_season['episodes'].each do |episode|
            e = Episode.where(show: show, season: season, number: episode['number']).first_or_create
            sleep 0.5
            episode_number = "e%02d" % episode['number']
            e.show = show
            e.season = season
            e.number = episode['number']
            e.ids = episode['ids']
            e.slug_ru = "#{season_number}#{episode_number}"
            e.slug_en = "#{season_number}#{episode_number}"
            e.title_en = episode['title']
            e.slug_en = episode['title'].parameterize unless episode['title'].nil?
            e.number_abs = episode['number_abs']
            e.description_en = episode['overview']
            e.first_aired = DateTime.parse episode['first_aired'] unless episode['first_aired'].nil?

            e.abs_name = "#{trakt_season['number']}-#{episode['number']}"

            unless episode['images']['screenshot']['full'].nil? || (e.screenshot.exists? && !@force_reload)
              # screenshot_status = Faraday.new.get(episode['images']['screenshot']['full']).status
              begin
                screenshot_full_src = episode['images']['screenshot']['full']
                if screenshot_full_src.present?
                  screenshot_full_src = screenshot_full_src.sub('medium', 'original')
                  e.screenshot = URI.parse(screenshot_full_src)
                end
              rescue
              end
              puts "reloading screenshot for episode #{e.number}"
            end

            translation = @tvdb.episode_translation episode['ids']["tvdb"]

            unless translation.nil?
              e.title_ru = translation[:title_ru] if translation[:title_ru] != episode['title']
              e.description_ru = translation[:description_ru]
              e.abs_name = "#{translation[:season]}-#{translation[:episode]}" if translation[:episode] > 0
              e.number_abs = translation[:episode] if translation[:episode] > 0
            end

            e.save
          end
        end
      end
    end
  end
end
