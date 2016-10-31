class Tmdb
  attr_accessor :ratelimit_limit
  attr_accessor :ratelimit_remaining
  attr_accessor :ratelimit_reset

  def initialize
    api_url = APP_CONFIG['tmdb_api_url']
    @api_key = APP_CONFIG['tmdb_api_key_v3']
    @img_url = APP_CONFIG['tmdb_img_url']
    @http = new_http_request_builder api_url
    @language = 'ru-RU'
  end

  def configuration
    check_ratelimit

    request = @http.get("/3/configuration") do |req|
      req.params['api_key'] = @api_key
    end

    set_ratelimit request.headers
    JSON.parse request.body
  end


  def find(external_id, source = 'imdb_id')
    check_ratelimit

    request = @http.get("/3/find/#{external_id}") do |req|
      req.params['language'] = @language
      req.params['api_key'] = @api_key
      req.params['external_source'] = source
    end

    set_ratelimit request.headers
    JSON.parse request.body
  end

  def genres
    check_ratelimit

    request = @http.get("/3/genre/tv/list") do |req|
      req.params['language'] = @language
      req.params['api_key'] = @api_key
    end

    set_ratelimit request.headers
    JSON.parse request.body
  end

  def show id
    check_ratelimit

    request = @http.get("/3/tv/#{id}") do |req|
      req.params['language'] = @language
      req.params['api_key'] = @api_key
      req.params['append_to_response'] = 'videos,images'
      req.params['include_image_language'] = 'en,ru,null'
    end

    set_ratelimit request.headers
    JSON.parse request.body
  end

  def show_images id, lang = nil
    check_ratelimit

    request = @http.get("/3/tv/#{id}/images") do |req|
      req.params['language'] = lang
      req.params['api_key'] = @api_key
    end

    set_ratelimit request.headers
    JSON.parse request.body
  end

  def show_videos id, lang = nil
    check_ratelimit

    request = @http.get("/3/tv/#{id}/videos") do |req|
      req.params['language'] = lang
      req.params['api_key'] = @api_key
    end

    set_ratelimit request.headers
    JSON.parse request.body
  end


  def season show_id, season_number
    check_ratelimit

    request = @http.get("/3/tv/#{show_id}/season/#{season_number}") do |req|
      req.params['language'] = @language
      req.params['api_key'] = @api_key
      req.params['append_to_response'] = 'videos,images'
      req.params['include_image_language'] = 'en,ru,null'
    end

    set_ratelimit request.headers
    JSON.parse request.body
  end

  def season_images show_id, season_number, lang = nil
    check_ratelimit

    request = @http.get("/3/tv/#{show_id}/season/#{season_number}/images") do |req|
      req.params['language'] = lang
      req.params['api_key'] = @api_key
    end

    set_ratelimit request.headers
    JSON.parse request.body
  end

  def episode show_id, season_number, episode_number
    check_ratelimit

    request = @http.get("/3/tv/#{show_id}/season/#{season_number}/episode/#{episode_number}") do |req|
      req.params['language'] = @language
      req.params['api_key'] = @api_key
      req.params['append_to_response'] = 'videos,images'
      req.params['include_image_language'] = 'en,ru,null'
    end

    set_ratelimit request.headers
    JSON.parse request.body
  end

  def episode_images show_id, season_number, episode_number, lang = nil
    check_ratelimit

    request = @http.get("/3/tv/#{show_id}/season/#{season_number}/episode/#{episode_number}/images") do |req|
      req.params['language'] = lang
      req.params['api_key'] = @api_key
    end

    set_ratelimit request.headers
    JSON.parse request.body
  end

  def img_fullpath img, style = 'original'
    "#{@img_url}#{style}#{img}"
  end

  private

  def check_ratelimit
    @ratelimit_limit = 40 if @ratelimit_limit.nil?
    @ratelimit_reset = 0 if @ratelimit_reset.nil?
    @ratelimit_remaining = @ratelimit_limit if @ratelimit_remaining.nil?

    if (@ratelimit_remaining <= 1 && @ratelimit_reset > 0)
      sleep (Time.now.to_i - @ratelimit_reset)
    end
  end

  def set_ratelimit headers
    limit = headers['x-ratelimit-limit']
    remaining = headers['x-ratelimit-remaining']
    reset = headers['x-ratelimit-reset']
    @ratelimit_limit = limit.to_i
    @ratelimit_remaining = remaining.to_i
    @ratelimit_reset = reset.to_i
  end


  def new_http_request_builder(api_url)
    Faraday.new(url: api_url) do |builder|
      builder.headers['Content-Type'] = 'application/json'
      builder.options.timeout = 50
      builder.options.open_timeout = 50
      builder.adapter Faraday.default_adapter
    end
  end
end
