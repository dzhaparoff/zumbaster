class SyncShowVideoJob < ProgressJob::Base
  require 'typhoeus/adapters/faraday'
  def initialize(show)
    @show = show
    @moonwalk = Moonwalk.new
  end

  def perform
    update_stage('SyncShowVideoJob')
    show = @show
    return false if show.ids['kp'].to_i == 0

    Translator.sync

    kp = show.ids['kp']
    moonwalk = @moonwalk.show kp

    update_progress_max(moonwalk.count)

    moonwalk.each do |m|
      translator_id = m['translator_id']

      moonwalk_episodes = @moonwalk.get_playlist_url_parallel kp, translator_id

      moonwalk_episodes[:playlists].each_pair do |season_number, episodes|
        season = Season.where(show: show, number: season_number).take
        episodes.each_pair do |episode_number, playlists|
          episode = Episode.where(show: show, season: season, number: episode_number).take
          translator = Translator.where(ex_id: translator_id).take
          translation = Translation.where(episode: episode, translator: translator).first_or_create
          translation.f4m = playlists['playlists']['manifest_f4m'] unless playlists['playlists'].nil?
          translation.m3u8 = playlists['playlists']['manifest_m3u8'] unless playlists['playlists'].nil?
          translation.moonwalk_token = playlists['token']
          translation.save
        end
      end
      update_progress
    end
  end

end
