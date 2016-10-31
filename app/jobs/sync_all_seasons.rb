class SyncAllSeasonsJob < ProgressJob::Base

  def initialize(show)
    @show = show
    @force_reload = true
  end

  def perform
    show = @show
    update_progress_max @show.aired_episodes

    update_stage('SyncAllSeasons')

    trakt_seasons = show.seasons_trakt

    trakt_seasons.each do |season|
      next if season['number'] == 0

      s = Season.where(show: show, number: season['number']).first_or_create

      season_number = "s%02d" % season['number']
      s.ids             = season['ids']

      s.episode_count   = season['episode_count']
      s.aired_episodes  = season['aired_episodes']

      s.slug_en         = "#{season_number}"
      s.slug_ru         = s.slug_en

      s.description_en = season['overview']

      s.save

      s.sync_by_tmdb
      s.sync_images_by_tmdb

      next if season['episodes'].nil?

      season['episodes'].each do |episode|
        e = Episode.where(show: show, season: s, number: episode['number']).first_or_create

        episode_number   = "e%02d" % episode['number']
        e.ids            = episode['ids']

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
        update_progress
      end
    end

    show.updated = DateTime.parse show.trakt_data['updated_at']
    show.save
  end

end
