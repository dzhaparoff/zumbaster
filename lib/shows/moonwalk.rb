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
    sleep 0.5
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
      v.each do |episode|
        request[k][episode] = "body"
      end
    end

    playlists = {}

    request.each_pair do|s, req|
      playlists[s] = {}
      req.each_pair do |e, r|
        playlists[s][e] = {}
        playlists[s][e]['token'] = "temp_token"
      end
    end

    {
        serial: serial,
        playlists: playlists
    }
  end


  def self.get_iframe_page(iframe,s,e)
    f = Faraday.new(url: 'http://alchemists.pw') do |builder|
      builder.use     :cookie_jar
      builder.adapter :net_http
      builder.request :url_encoded
      builder.headers['Accept'] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
      builder.headers['Accept-Language'] = "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,bg;q=0.2,de;q=0.2,es;q=0.2,fr;q=0.2,it;q=0.2,mk;q=0.2,tr;q=0.2"
      builder.headers['Cache-Control'] = "no-cache"
      builder.headers['Connection']    = "keep-alive"
      builder.headers['Host']          = "alchemists.pw"
      builder.headers['Pragma']        = "no-cache"
      builder.headers['Referer']       = "http://baskino.co/series/comedy/2040-kremnievaya-dolina-2016-besplatno.html"
      builder.headers['Upgrade-Insecure-Requests'] = "1"
      builder.headers['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36"
    end

    {
        request: f.get(iframe[18..-1], season: s, episode: e),
        faraday: f
    }
  end

  def self.playlist_getter faraday, video_token, csrf_token, frame_commit, argv_name, argv_value, referer
    return false unless video_token

    playlist_request = faraday.post do |b|
      b.url "/manifests/video/#{video_token}/all"
      b.headers['Connection'] = 'keep-alive'
      b.headers['Cache-Control'] = 'no-cache'
      b.headers['Host'] = 'alchemists.pw'
      b.headers['Origin'] = 'http://alchemists.pw'
      b.headers['Referer'] = referer.sub!("moonwalk.cc", "alchemists.pw")
      b.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36'
      b.headers['Accept'] = '*/*'
      b.headers['Pragma'] = 'no-cache'
      b.headers['Accept-Encoding'] = 'gzip, deflate'
      b.headers['Accept-Language'] = 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,bg;q=0.2,de;q=0.2,es;q=0.2,fr;q=0.2,it;q=0.2,mk;q=0.2,tr;q=0.2,pt;q=0.2'
      b.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'

      b.headers['X-CSRF-Token'] = csrf_token
      b.headers['X-Requested-With'] = 'XMLHttpRequest'
      b.headers['X-Access-Level'] = frame_commit

      argv_name = 'c90b4ca500a12b91e2b54b2d4a1e4fb7'
      argv_value = 'cc5610c93fa23befc2d244a76500ee6c'

      b.body = URI.encode_www_form({
                                       content_type: 'serial',
                                       mw_key: '1ffd4aa558cc51f5a9fc6888e7bc5cb4',
                                       mw_pid: 769,
                                       p_domain_id: 473125,
                                       ad_attr: 0,
                                       :"c90b4ca500a12b91e2b54b2d4a1e4fb7" => 'cc5610c93fa23befc2d244a76500ee6c'
                                   })
    end    
    # JSON.parse Zlib::GzipReader.new(StringIO.new(playlist_request.body), encoding: 'ASCII-8BIT').read
    JSON.parse playlist_request.body
  end

  private

  def new_http_request_parallel api_url, api_key
    manager = Typhoeus::Hydra.new(:max_concurrency => 1)
    Faraday.new(url: api_url, parallel_manager: manager) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36'
      builder.headers['Host'] = 'alchemists.pw'
      builder.params['api_token'] = api_key
      builder.adapter :typhoeus
    end
  end

  def new_http_request_builder api_url, api_key
    Faraday.new(url: api_url) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36'
      builder.headers['Host'] = 'alchemists.pw'
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
