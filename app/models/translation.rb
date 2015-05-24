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

    http = Faraday.new(url: APP_CONFIG['m_api_url']) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0'
      builder.params['api_token'] = APP_CONFIG['m_api_key']
      builder.adapter Faraday.default_adapter
    end

    request = http.get('/api/serial_episodes.json',
                        kinopoisk_id: episode.show.ids['kp'],
                        translator_id: translator.ex_id)

    serial = JSON.parse request.body
    main_iframe_link = serial['serial']['iframe_url'].to_s

    request2 = Faraday.get main_iframe_link,
                                    season: s,
                                    episode: e

    doc = Nokogiri::HTML.parse(request2.body)
    script = doc.search('body > script')[1]

    false if script.nil?
    false if script.content.nil?

    video_token = script.content.to_s.scan(/video_token\: \'([a-zA-Z0-9]+)\'/).first.first

    new_playlist = Moonwalk.playlist_getter video_token

    f4m = new_playlist['manifest_f4m']
    m3u8 = new_playlist['manifest_m3u8']
    save
  end
end
