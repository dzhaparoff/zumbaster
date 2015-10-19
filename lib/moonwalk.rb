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
          request[k][episode] = @http_parallel.get main_iframe_link[18..-1],
                              season: k,
                              episode: episode
        end
      end
    end

    playlists = fill_playlists request

    {
        serial: serial,
        playlists: playlists
    }
  end

  def self.playlist_getter video_token
    return false if video_token == false

     f = Faraday.new(url: APP_CONFIG['m_api_url']) do |builder|
        builder.headers['Content-Type'] = 'application/json'
        builder.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0'
        builder.adapter Faraday.default_adapter
        builder.params['d_id'] = 21609
        builder.params['video_token'] = video_token
        builder.params['content_type'] = 'serial'
        builder.params['access_key'] = '0fb74eb4b2c16d45fe'
     end

    playlist_request = f.post '/sessions/create_session'

    JSON.parse playlist_request.body
  end

  private

  def new_http_request_parallel api_url, api_key
    manager = Typhoeus::Hydra.new(:max_concurrency => 1)
    Faraday.new(url: api_url, parallel_manager: manager) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0'
      builder.params['api_token'] = api_key
      # builder.adapter Faraday.default_adapter
      builder.adapter :typhoeus
    end
  end

  def new_http_request_builder api_url, api_key
    Faraday.new(url: api_url) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0'
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
          doc = Nokogiri::HTML.parse(r.body)

          video_token = false

          doc.search('body > script').each do |script|
            video_token = check_script_tag script, video_token
          end

          playlists[s][e]['token'] = video_token
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
