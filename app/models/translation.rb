class Translation < ActiveRecord::Base
  belongs_to :episode
  belongs_to :translator

  def translation_video_exist?
    return false if m3u8.nil?
    responce = Faraday.get(m3u8)
    responce.status == 200
  end

  def manifest type
    sync_translation_video unless translation_video_exist?

    manifest = type == :mobile ? m3u8 : f4m

    f = Faraday.new do |builder|
      builder.adapter :net_http
      builder.response :logger
      builder.headers['Accept'] = '*/*'
      builder.headers['Accept-Encoding'] = 'gzip, deflate'
      builder.headers['Connection'] = 'keep-alive'
      builder.headers['Host'] = 'moonwalk.cc'
      builder.headers['Referer'] = "http://moonwalk.cc/video/#{moonwalk_token}/iframe"
      builder.headers['X-Requested-With'] = 'ShockwaveFlash/19.0.0.226'
      builder.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36'
    end

    f.get manifest
  end

  def sync_translation_video

    if episode.abs_name.nil?
      e = episode.number
      s = episode.season.number
    else
      s, e = episode.abs_name.split('-')
    end

    moonwalk = Moonwalk.new

    tansl_id = translator.nil? ? nil : translator.ex_id
    serial = moonwalk.show_episodes(episode.show.ids['kp'], tansl_id)

    main_iframe_link = serial['serial']['iframe_url'].to_s

    request = Moonwalk.get_iframe_page(main_iframe_link, s, e)

    video_token = false

    doc = Nokogiri::HTML.parse(request.body)
    doc.search('body > script').each do |script|
      video_token = check_script_tag script, video_token
    end

    return false if video_token == false

    new_playlist = Moonwalk.playlist_getter video_token

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
