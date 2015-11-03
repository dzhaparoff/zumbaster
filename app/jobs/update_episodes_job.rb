class UpdateEpisodesJob < ActiveJob::Base
  queue_as :default

  def perform(*args)

    date = DateTime.now - 7.days

    7.times do |increment|

      date = date + increment.day

      episodes = Episode.for_date date

      @moonwalk = Moonwalk.new

      episodes.each do |episode_for_update|
        show = episode_for_update.show
        season = episode_for_update.season

        kp = show.ids['kp']
        moonwalk = @moonwalk.show kp

        moonwalk.each do |m|
          translator_id = m['translator_id']
          moonwalk_episodes = @moonwalk.get_playlist_url_parallel kp, translator_id
          moonwalk_episodes[:playlists].each_pair do |season_number, m_episodes|
            next if season_number != season.number
            m_episodes.each_pair do |episode_number, playlists|
              episode = Episode.where(show: show, abs_name: "#{season_number.to_i}-#{episode_number.to_i}").take
              translator = Translator.where(ex_id: translator_id).take
              translation = Translation.where(episode: episode, translator: translator).first_or_create
              translation.moonwalk_token = playlists['token'] unless translation.moonwalk_token == 'temp_token'
              translation.save
            end
          end
        end
      end
    end
  end
end
