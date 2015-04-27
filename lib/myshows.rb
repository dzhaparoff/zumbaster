class Myshows
  def initialize
    @http = new_http_request_builder
  end

  def get_top_shows
    JSON.parse @http.get("/shows/top/all/").body
  end

  def get_show id
    JSON.parse @http.get("/shows/#{id}").body
  end

  private

  def new_http_request_builder
    Faraday.new(url: APP_CONFIG['myshows_api_url']) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.adapter Faraday.default_adapter
    end
  end
end