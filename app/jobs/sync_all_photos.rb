class SyncAllPhotosJob < ProgressJob::Base

  def perform
    @trakt = Trakt.new

    shows = Show.all

    update_progress_max shows.count
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

        s.poster = URI.parse season['images']['poster']['full']
        s.thumb = URI.parse season['images']['thumb']['full']
        s.save

        next if season['episodes'].nil?

        season['episodes'].each do |episode|
          e = Episode.where(show: show, season: s, number: episode['number']).first
          next if e.nil?

          screenshot_status = Faraday.new.get(episode['images']['screenshot']['full']).status
          e.screenshot = URI.parse episode['images']['screenshot']['full'] if screenshot_status == 200

          translation = @tvdb.episode_translation episode['ids']["tvdb"]

          unless translation.nil?
            e.title_ru = translation[:title_ru] if translation[:title_ru] != episode['title']
            e.description_ru = translation[:description_ru]
            e.number_abs = translation[:episode] if translation[:episode] > 0
          end

          e.save
        end
      end

      update_progress
    end
  end
end