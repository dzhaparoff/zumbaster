class SyncAllSeasonsJob < ProgressJob::Base

  def initialize(show)
    @show = show
    @force_reload = false
  end

  def perform
    @trakt = Trakt.new
    @tvdb = Tvdb.new
    show = @show

    update_progress_max @show.aired_episodes

    update_stage('SyncAllSeasons')

    imdb = "tt%07d" % show.ids['imdb'].to_i
    trakt_seasons = @trakt.show_seasons imdb

    return false if trakt_seasons.nil?

    trakt_seasons.each do |season|
      next if season['number'] == 0

      s = Season.where(show: show, number: season['number']).first_or_create

      season_number = "s%02d" % season['number']
      s.number = season['number']
      s.ids = season['ids']
      s.episode_count = season['episode_count']
      s.aired_episodes = season['aired_episodes']
      s.slug_ru = s.slug_en = "#{season_number}"
      s.description_ru = season['overview']

      s.poster = URI.parse season['images']['poster']['full'] unless season['images']['poster']['full'].nil?
      s.thumb = URI.parse season['images']['thumb']['full'] unless season['images']['thumb']['full'].nil?

      s.save

      next if season['episodes'].nil?

      season['episodes'].each do |episode|
        e = Episode.where(show: show, season: s, number: episode['number']).first_or_create

        episode_number = "e%02d" % episode['number']
        e.show = show
        e.season = s
        e.number = episode['number']
        e.ids = episode['ids']
        e.slug_ru = "#{season_number}#{episode_number}"
        e.slug_en = "#{season_number}#{episode_number}"
        e.title_en = episode['title']
        e.slug_en = episode['title'].parameterize unless episode['title'].nil?
        e.number_abs = episode['number_abs']
        e.description_en = episode['overview']
        e.first_aired = DateTime.parse episode['first_aired'] unless episode['first_aired'].nil?

        e.abs_name = "#{season['number']}-#{episode['number']}"

        unless episode['images']['screenshot']['full'].nil? || (e.screenshot.exists? && !@force_reload)
          screenshot_status = Faraday.new.get(episode['images']['screenshot']['full']).status
          e.screenshot = URI.parse episode['images']['screenshot']['full'] if screenshot_status == 200
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
        update_progress
      end
    end

    trakt_show = @trakt.show(imdb)
    show.updated = DateTime.parse trakt_show['updated_at']
    show.save
  end

end
