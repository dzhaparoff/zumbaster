class Moonwalk

  def initialize

    api_url = APP_CONFIG['m_api_url']
    api_key = APP_CONFIG['m_api_key']
    @http = new_http_request_builder api_url, api_key

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

  def get_playlist_url(kinopoisk_id, translator_id)
    request = @http.get '/api/serial_episodes.json',
                        kinopoisk_id: kinopoisk_id,
                        translator_id: translator_id,
                        api_token: Videoplayer::Constants::M_API_KEY

    serial = JSON.parse request.body

    main_iframe_link = serial['serial']['iframe_url'].to_s

    seasons_episodes = {}

    serial['season_episodes_count'].each do |se|
      seasons_episodes[se['season_number']] = se['episodes_count']
    end

    playlists = {}

    seasons_episodes.sort.to_h.each_pair do |k,p|

      playlists[k] = {}

      (1..p).each do |episode|

        playlists[k][episode] = {}

        request = @http.get main_iframe_link[18..-1],
                            season: k,
                            episode: episode



        doc = Nokogiri::HTML.parse(request.body)

        script = doc.search('body > script')[1]

        video_token = script.content.to_s.scan(/video_token\: \'([a-zA-Z0-9]+)\'/).first

        playlist_request = @http.post '/sessions/create_session/',
                                      URI.encode_www_form(partner: nil,
                                                          d_id: 177,
                                                          video_token: video_token,
                                                          content_type: 'serial',
                                                          access_key: 'zNW4q9pL82sHxV')

        playlists[k][episode] = JSON.parse playlist_request.body

      end
    end

    return playlists
  end

  private

  def new_http_request_builder api_url, api_key
    Faraday.new(url: api_url) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.params['api_token'] = api_key
      builder.adapter Faraday.default_adapter
    end
  end
end
