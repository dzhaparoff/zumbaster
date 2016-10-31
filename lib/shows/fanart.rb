class Fanart
  def initialize
    api_url = APP_CONFIG['fanart_api_url']
    @api_key = APP_CONFIG['fanart_api_key']
    @http = new_http_request_builder api_url
  end

  def images id
    request = @http.get("/v3/tv/#{id}") do |req|
      req.params['api_key'] = @api_key
    end

    JSON.parse request.body
  end

  private

  def new_http_request_builder(api_url)
    Faraday.new(url: api_url) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.options.timeout = 50
      builder.options.open_timeout = 50
      builder.adapter Faraday.default_adapter
    end
  end
end
