class Translation < ActiveRecord::Base
  belongs_to :episode
  belongs_to :translator

  default_scope do
    order('translator_id')
  end

  def translation_video_exist? type
    return false if Time.at(expires) < Time.now
    if type != :mobile
      return false if f4m.nil?
      responce = Faraday.get(f4m)
      responce.status == 200
    else
      return false if m3u8.nil?
      responce = Faraday.get(m3u8)
      responce.status == 200
    end
  end

  def manifest type
    sync_translation_video unless translation_video_exist? type
    m = type == :mobile ? m3u8 : f4m

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
    f.get m
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

    iframe = Moonwalk.get_iframe_page(main_iframe_link, s, e)

    referer = main_iframe_link + "?season=#{s}"

    doc = Nokogiri::HTML.parse(iframe[:request].body)
    video_token = false
    secret_key = false
    subtitles = false
    uuid = false

    csrf_token = doc.search('head > meta[name="csrf-token"]')[0]['content']

    doc.search('body > script').each do |script|
      unless video_token && uuid
        subtitles   = find_subtitles script
        video_token = check_script_tag script, video_token
        uuid        = find_uuid script, uuid
      end
    end

    self.subtitles = subtitles

    # secret_key = encode_request_header secret_key

    return false if video_token == false

    new_playlist = Moonwalk.playlist_getter iframe[:faraday], video_token, csrf_token, uuid, referer

    if new_playlist.is_a? Hash
     new_playlist = new_playlist.first[1]
    end

    self.f4m = new_playlist['manifest_f4m']
    self.m3u8 = new_playlist['manifest_m3u8']
    self.expires = new_playlist['manifest_f4m'][/expired=(\d+)/].delete('expired=').to_i
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

  def find_subtitles script
    raw = script.text.to_s.scan(/src: \"(http:\/\/[a-zA-Z0-9.]+\/static\/srt\/subtitles\/[a-zA-Z0-9-._]+\/[a-zA-Z0-9-._]+)\"/)
    return false if raw.nil? || raw.size == 0 || raw.first.nil?
    raw.first.first
  end

  def find_uuid script, uuid
    return uuid if uuid.to_s.length > 5
    return false if script.nil?
    return false if script.content.nil?

    uuid_raw = script.text.to_s.scan(/uuid\: \'([a-zA-Z0-9]+)\'/)
    return false if uuid_raw.first.nil? || uuid_raw.nil? || uuid_raw.size == 0

    uuid_raw.first.first
  end

  def encode_request_header string
    cxt = V8::Context.new
    cxt.eval(%\
      var encode = function(e){
            var _keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
            var t = "";
            var n, r, i, s, o, u, a;
            var f = 0;
            while (f < e.length) {
                n = e.charCodeAt(f++);
                r = e.charCodeAt(f++);
                i = e.charCodeAt(f++);
                s = n >> 2;
                o = (n & 3) << 4 | r >> 4;
                u = (r & 15) << 2 | i >> 6;
                a = i & 63;
                if (isNaN(r)) {
                    u = a = 64
                } else if (isNaN(i)) {
                    a = 64
                }
                t = t + _keyStr.charAt(s) + _keyStr.charAt(o) + _keyStr.charAt(u) + _keyStr.charAt(a)
            }
          return t;
        }
    \)
    cxt[:encode].call(string)
  end
end
