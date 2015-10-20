class Moonwalk

  def initialize
    api_url = APP_CONFIG['m_api_url']
    api_key = APP_CONFIG['m_api_key']
    @http = new_http_request_builder api_url, api_key
    @http_parallel = new_http_request_parallel api_url, api_key
  end

  def show(kinopoisk_id)
    JSON.parse @http.get("/api/videos.json", kinopoisk_id: kinopoisk_id).body
  end

  def translators
    JSON.parse @http.get("/api/translators.json").body
  end

  def show_episodes(kinopoisk_id, translator_id)
    JSON.parse @http.get("/api/serial_episodes.json", kinopoisk_id: kinopoisk_id, translator_id: translator_id).body
  end

  def get_playlist_url_parallel(kinopoisk_id, translator_id)
    request = @http.get('/api/serial_episodes.json',
                        kinopoisk_id: kinopoisk_id,
                        translator_id: translator_id)

    serial = JSON.parse request.body

    main_iframe_link = serial['serial']['iframe_url'].to_s

    seasons_episodes = {}

    serial['season_episodes_count'].each do |se|
      seasons_episodes[se['season_number']] = se['episodes'].sort
    end

    request = {}

    seasons_episodes.sort.to_h.each_pair do |k, v|
      request[k] = {}
      @http_parallel.in_parallel do
        v.each do |episode|
          # request[k][episode] = @http_parallel.get main_iframe_link[18..-1],
          #                     season: k,
          #                     episode: episode

          request[k][episode] = "body"
        end
      end
    end

    playlists = fill_playlists request

    {
        serial: serial,
        playlists: playlists
    }
  end

  def self.playlist_getter video_token, m_expired, m_token
    return false unless video_token

     f = Faraday.new(url: APP_CONFIG['m_api_url']) do |builder|
        builder.adapter Faraday.default_adapter
        builder.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36'
        builder.headers['Accept'] = '*/*'
        builder.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        builder.headers['Host'] = 'moonwalk.cc'
        builder.headers['Origin'] = 'http://moonwalk.cc'
        builder.headers['referer'] = "http://moonwalk.cc"
        builder.headers['X-MOON-EXPIRED'] = m_expired
        builder.headers['X-MOON-TOKEN'] = m_token
        builder.headers['X-Requested-With'] = 'XMLHttpRequest'
        builder.params['partner'] = nil
        builder.params['d_id'] = 21609
        builder.params['video_token'] = video_token
        builder.params['content_type'] = 'movie'
        builder.params['access_key'] = '0fb74eb4b2c16d45fe'
     end

    playlist_request = f.post '/sessions/create_session'

    JSON.parse playlist_request.body
  end

  def self.get_iframe_page(iframe,s,e)
    f = Faraday.new(url: APP_CONFIG['m_api_url']) do |builder|
      builder.adapter Faraday.default_adapter
      builder.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36'
      builder.headers['Host'] = 'moonwalk.cc'
    end

    f.get iframe[18..-1], season: s, episode: e
  end

  def self.get_m_headers(token)
    f = Faraday.new(url: APP_CONFIG['m_api_url']) do |builder|
      builder.adapter Faraday.default_adapter
      builder.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36'
      builder.headers['Host'] = 'moonwalk.cc'
    end

    request = f.get "/video/#{token}/iframe"

    doc = Nokogiri::HTML.parse(request.body)

    m_expired = nil
    m_token = nil

    doc.search('body > script').each do |script|

      e = script.text.to_s.scan(/X-MOON-EXPIRED[\"\'\s\=\,\:]*?([a-zA-Z0-9]+)/)
      t = script.text.to_s.scan(/X-MOON-TOKEN[\"\'\s\=\,\:]*?([a-zA-Z0-9]+)/)

      m_expired = e.first.first if e.length > 0
      m_token   = t.first.first if t.length > 0

      break if m_expired != nil && m_token != nil
    end

    {
        m_expired: m_expired,
        m_token: m_token
    }
  end

  private

  def new_http_request_parallel api_url, api_key
    manager = Typhoeus::Hydra.new(:max_concurrency => 1)
    Faraday.new(url: api_url, parallel_manager: manager) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36'
      builder.headers['Host'] = 'moonwalk.cc'
      builder.params['api_token'] = api_key
      builder.adapter :typhoeus
    end
  end

  def new_http_request_builder api_url, api_key
    Faraday.new(url: api_url) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36'
      builder.headers['Host'] = 'moonwalk.cc'
      builder.params['api_token'] = api_key
      builder.adapter Faraday.default_adapter
    end
  end

  def fill_playlists request
    playlists = {}
    request.each_pair do|s, req|
      playlists[s] = {}
      req.each_pair do |e, r|
          playlists[s][e] = {}
          # doc = Nokogiri::HTML.parse(r.body)
          #
          # video_token = false
          #
          # doc.search('body > script').each do |script|
          #   video_token = check_script_tag script, video_token
          # end

          playlists[s][e]['token'] = "temp_token"
      end
    end
    playlists
  end

  def check_script_tag(script, video_token)
    return video_token if video_token.to_s.length > 5
    return false if script.nil?
    return false if script.content.nil?

    video_token_raw = script.text.to_s.scan(/video_token\: \'([a-zA-Z0-9]+)\'/)
    return false if video_token_raw.first.nil? || video_token_raw.nil? || video_token_raw.size == 0

    video_token_raw.first.first
  end
end
