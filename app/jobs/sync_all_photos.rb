class SyncAllPhotosJob < ProgressJob::Base

  def perform
    @trakt = Trakt.new
    @tvdb = Tvdb.new

    shows = Show.all

    update_progress_max Show.count
    update_stage('SyncAllPhotosJob')

    shows.each do |show|
      next if File.exist?(show.poster.url)

      next unless show.ids['imdb'].to_i > 0

      imdb = "tt%07d" % show.ids['imdb'].to_i

      trakt_show = @trakt.show imdb
      next if trakt_show.nil?

      begin
        poster_full_src = trakt_show['images']['poster']['full']
        if poster_full_src.present? && !File.exist?(show.poster.url)
          poster_full_src = poster_full_src.sub('medium', 'original')
          show.poster = URI.parse(poster_full_src)
        end
      rescue
      end

      begin
        fanart_full_src = trakt_show['images']['fanart']['full']
        if fanart_full_src.present? && !File.exist?(show.fanart.url)
          fanart_full_src = fanart_full_src.sub('medium', 'original')
          show.fanart = URI.parse(fanart_full_src)
        end
      rescue
      end

      begin
        logo_full_src = trakt_show['images']['logo']['full']
        if logo_full_src.present? && !File.exist?(show.logo.url)
          logo_full_src = logo_full_src.sub('medium', 'original')
          show.logo = URI.parse(logo_full_src)
        end
      rescue
      end

      begin
        clearart_full_src = trakt_show['images']['clearart']['full']
        if clearart_full_src.present? && !File.exist?(show.clearart.url)
          clearart_full_src = clearart_full_src.sub('medium', 'original')
          show.clearart = URI.parse(clearart_full_src)
        end
      rescue
      end

      begin
        banner_full_src = trakt_show['images']['banner']['full']
        if banner_full_src.present? && !File.exist?(show.banner.url)
          banner_full_src = banner_full_src.sub('medium', 'original')
          show.banner = URI.parse(banner_full_src)
        end
      rescue
      end

      begin
        thumb_full_src = trakt_show['images']['thumb']['full']
        if thumb_full_src.present? && !File.exist?(show.thumb.url)
          thumb_full_src = thumb_full_src.sub('medium', 'original')
          show.thumb = URI.parse(thumb_full_src)
        end
      rescue
      end


      show.save

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

          end

      end
      update_progress
    end
  end

  def max_run_time
    9999999999
  end

end
