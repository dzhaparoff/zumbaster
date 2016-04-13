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

      trakt_seasons = @trakt.show_seasons imdb

      return false if trakt_seasons.nil?

      trakt_seasons.each do |season|
        next if season['number'] == 0

        s = Season.where(show: show, number: season['number']).first

        next if s.nil?

        s.poster = URI.parse season['images']['poster']['full'] if !season['images']['poster']['full'].nil? && !File.exist?(s.poster.url)
        sleep 0.1

        s.thumb = URI.parse season['images']['thumb']['full'] if !season['images']['thumb']['full'].nil? && !File.exist?(s.thumb.url)
        sleep 0.1

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
end