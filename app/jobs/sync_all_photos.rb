class SyncAllPhotosJob < ProgressJob::Base

  def perform
    @trakt = Trakt.new

    shows = Shows.all

    update_progress_max shows.count
    update_stage('SyncAllPhotosJob')

    shows.each do |show|
      next unless show.ids['imdb'].to_i > 0

      imdb = "tt%07d" % show.ids['imdb'].to_i
      trakt_show = @trakt.show imdb

      next if trakt_show.nil?

      show.poster = URI.parse(trakt_show['images']['poster']['full']) unless trakt_show['images']['poster']['full'].nil?
      show.fanart = URI.parse(trakt_show['images']['fanart']['full']) unless trakt_show['images']['fanart']['full'].nil?
      show.logo = URI.parse(trakt_show['images']['logo']['full']) unless trakt_show['images']['logo']['full'].nil?
      show.clearart = URI.parse(trakt_show['images']['clearart']['full']) unless trakt_show['images']['clearart']['full'].nil?
      show.banner = URI.parse(trakt_show['images']['banner']['full']) unless trakt_show['images']['banner']['full'].nil?
      show.thumb = URI.parse(trakt_show['images']['thumb']['full']) unless trakt_show['images']['thumb']['full'].nil?

      show.save

      sleep 0.01

      update_progress
    end
  end
end