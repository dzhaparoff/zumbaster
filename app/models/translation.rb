class Translation < ActiveRecord::Base
  belongs_to :episode
  belongs_to :translator

  def translation_video_exist?
    return false if m3u8.nil?
    responce = Faraday.get(m3u8)
    responce.status == 200
  end

  def sync_translation_video
    e = episode.number
    s = episode.season.number
    moonwalk = Moonwalk.new

    tansl_id = translator.nil? ? nil : translator.ex_id
    serial = moonwalk.show_episodes(episode.show.ids['kp'], tansl_id)

    main_iframe_link = serial['serial']['iframe_url'].to_s

    request = Moonwalk.get_iframe_page(main_iframe_link, s, e)

    doc = Nokogiri::HTML.parse(request.body)

    video_token = false

    doc.search('body > script').each do |script|
      video_token = check_script_tag script, video_token
    end

    return false if video_token == false

    meta_tokens = Moonwalk.get_m_headers video_token

    new_playlist = Moonwalk.playlist_getter video_token, meta_tokens[:m_expired], meta_tokens[:m_token]

    ap video_token
    ap meta_tokens
    ap new_playlist

    self.f4m = new_playlist['manifest_f4m']
    self.m3u8 = new_playlist['manifest_m3u8']
    self.moonwalk_token = video_token

    self.save
  end

  private

  def check_script_tag(script, video_token)
    return video_token if video_token.to_s.length > 5
    return false if script.nil?
    return false if script.content.nil?

    video_token_raw = script.text.to_s.scan(/video_token\: \'([a-zA-Z0-9]+)\'/)
    return false if video_token_raw.first.nil? || video_token_raw.nil? || video_token_raw.size == 0

    video_token_raw.first.first
  end
end
