class Kinopoisk

  def initialize
    @http = new_http_request_builder APP_CONFIG['kinopoisk_api_url']
  end

  def rating(kinopoisk_id)
    rating = Nokogiri::Slop @http.get("http://rating.kinopoisk.ru/#{kinopoisk_id}.xml").body

    {
        kp: rating.rating.kp_rating.content.to_f,
        kp_num_vote: rating.rating.kp_rating['num_vote'],
        imdb: rating.rating.imdb_rating.content.to_f,
        imdb_num_vote: rating.rating.imdb_rating['num_vote'],
    }
  end

  private

  def new_http_request_builder(api_url)
    Faraday.new(url: api_url) do |builder|
      builder.adapter Faraday.default_adapter
    end
  end
end