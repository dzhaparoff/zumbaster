class Tvdb
  def initialize
    api_url = APP_CONFIG['tvdb_api_url']
    @api_key = APP_CONFIG['tvdb_api_key']
    @http = new_http_request_builder api_url
  end

  def episode_translation id
    res =  @http.get("/api/#{@api_key}/episodes/#{id}/ru.xml")
    unless res.status == 404
      body = Nokogiri::XML res.body
      overview = body.xpath "//Data//Episode//Overview"
      title = body.xpath "//Data//Episode//EpisodeName"
      dvd_season = body.xpath "//Data//Episode//DVD_season"
      dvd_episode = body.xpath "//Data//Episode//DVD_episodenumber"
      {
          title_ru: title.text,
          description_ru: overview.text,
          season: dvd_season.text.to_i,
          episode: dvd_episode.text.to_i
      }
    end
  end

  def show_updates
    #TODO: make update
  end

  private

  def new_http_request_builder(api_url)
    Faraday.new(url: api_url) do |builder|
      builder.options.timeout = 10
      builder.options.open_timeout = 10
      builder.adapter Faraday.default_adapter
    end
  end
end