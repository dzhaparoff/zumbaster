class Trakt
  def initialize
    api_url = APP_CONFIG['trakt_api_url']
    api_key = APP_CONFIG['trakt_api_key']
    @http = new_http_request_builder api_url, api_key
  end

  def genres
    JSON.parse @http.get('/genres/shows').body
  end

  def popular_shows
    JSON.parse @http.get('/shows/popular', limit: 100, page: 1).body
  end

  def trending_shows
    JSON.parse @http.get('/shows/trending', limit: 20, page: 1).body
  end

  def updates date
    JSON.parse @http.get("/shows/updates/#{date}", limit: 100, page: 1).body
  end

  def show(id_or_slug)
    res = @http.get("/shows/#{id_or_slug}", extended: "full,images")
    JSON.parse res.body unless res.status == 404
  end

  def show_aliases(id_or_slug)
    JSON.parse @http.get("/shows/#{id_or_slug}/aliases").body
  end

  def show_translations(id_or_slug)
    res =  @http.get("/shows/#{id_or_slug}/translations/ru", extended: "full, episodes")
    JSON.parse res.body unless res.status == 404
  end

  def show_people(id_or_slug)
    JSON.parse @http.get("/shows/#{id_or_slug}/people", extended: "full,images").body
  end

  def show_seasons(id_or_slug)
    res = @http.get("/shows/#{id_or_slug}/seasons", extended: "full,images,episodes")
    JSON.parse res.body unless res.status == 404
  end

  def show_season(id_or_slug, season)
    res = @http.get("/shows/#{id_or_slug}/seasons/#{season}", extended: "full,images,episodes")
    JSON.parse res.body unless res.status == 404
  end

  def show_episodes(id, season, episode)
    res = @http.get("/shows/#{id}/seasons/#{season}/episodes/#{episode}", extended: "full,images")
    JSON.parse res.body unless res.status == 404
  end

  private

  def new_http_request_builder(api_url, api_key)
    Faraday.new(url: api_url) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.headers['trakt-api-version'] = '2'
      builder.headers['trakt-api-key'] = api_key
      builder.options.timeout = 10
      builder.options.open_timeout = 10
      builder.adapter Faraday.default_adapter
    end
  end
end
