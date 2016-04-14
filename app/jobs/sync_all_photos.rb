class SyncAllPhotosJob < ProgressJob::Base

  def perform
    @trakt = Trakt.new
    @tvdb = Tvdb.new

    shows = Show.all

    update_progress_max Episode.count
    update_stage('SyncAllPhotosJob')

    shows.each do |show|
      next unless show.ids['imdb'].to_i > 0

      imdb = "tt%07d" % show.ids['imdb'].to_i


      trakt_show = @trakt.show imdb
      next if trakt_show.nil?

      show.poster = URI.parse(trakt_show['images']['poster']['full']) unless trakt_show['images']['poster']['full'].nil? || File.exist?(show.poster.url)
      show.fanart = URI.parse(trakt_show['images']['fanart']['full']) unless trakt_show['images']['fanart']['full'].nil? || File.exist?(show.fanart.url)
      show.logo = URI.parse(trakt_show['images']['logo']['full']) unless trakt_show['images']['logo']['full'].nil? || File.exist?(show.logo.url)
      show.clearart = URI.parse(trakt_show['images']['clearart']['full']) unless trakt_show['images']['clearart']['full'].nil? || File.exist?(show.clearart.url)
      show.banner = URI.parse(trakt_show['images']['banner']['full']) unless trakt_show['images']['banner']['full'].nil? || File.exist?(show.banner.url)
      show.thumb = URI.parse(trakt_show['images']['thumb']['full']) unless trakt_show['images']['thumb']['full'].nil? || File.exist?(show.thumb.url)

      sleep 0.05

      trakt_seasons = @trakt.show_seasons imdb

      next if  trakt_seasons.nil?

      trakt_seasons.each do |season|
        next if season['number'] == 0

        s = Season.where(show: show, number: season['number']).first

        next if s.nil?

          if !File.exist?(s.poster.url) && !season['images']['poster']['full'].nil?
            poster_status = Faraday.new.get(season['images']['poster']['full']).status
            sleep 0.1
            s.poster = URI.parse season['images']['poster']['full'] if poster_status == 200
            sleep 0.1
          end

          if !File.exist?(s.thumb.url) && !season['images']['thumb']['full'].nil?
            thumb_status = Faraday.new.get(season['images']['thumb']['full']).status
            sleep 0.1
            s.thumb = URI.parse season['images']['thumb']['full'] if thumb_status == 200
            sleep 0.1
          end

          s.save

          next if season['episodes'].nil?

          season['episodes'].each do |episode|
            e = Episode.where(show: show, season: s, number: episode['number']).first
            next if e.nil? || episode['images']['screenshot']['full'].nil? || File.exist?(e.screenshot.url)

            screenshot_status = Faraday.new.get(episode['images']['screenshot']['full']).status
            sleep 0.1

            e.screenshot = URI.parse episode['images']['screenshot']['full'] if screenshot_status == 200

            translation = @tvdb.episode_translation episode['ids']["tvdb"]

            unless translation.nil?
              e.title_ru = translation[:title_ru] if translation[:title_ru] != '' && translation[:title_ru] != episode['title']
              e.description_ru = translation[:description_ru] if translation[:description_ru] != ''
            end

            e.save

            sleep 0.5
            update_progress
          end

      end
    end
  end

  def max_run_time
    9999999999
  end

end