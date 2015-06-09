class Translation < ActiveRecord::Base
  belongs_to :episode
  belongs_to :translator

  def translation_video_exist?
    responce = Faraday.get(m3u8)
    responce.status == 200
  end

  def sync_translation_video
    e = episode.number
    s = episode.season.number
    moonwalk = Moonwalk.new
    serial = moonwalk.show_episodes(episode.show.ids['kp'], translator.ex_id)

    main_iframe_link = serial['serial']['iframe_url'].to_s

    request = Faraday.get main_iframe_link,
                                    season: s,
                                    episode: e

    doc = Nokogiri::HTML.parse(request.body)
    script = doc.search('body > script')[1]

    false if script.nil?
    false if script.content.nil?

    video_token = script.content.to_s.scan(/video_token\: \'([a-zA-Z0-9]+)\'/).first.first

    new_playlist = Moonwalk.playlist_getter video_token

    self.f4m = new_playlist['manifest_f4m']
    self.m3u8 = new_playlist['manifest_m3u8']

    self.save
  end
end
