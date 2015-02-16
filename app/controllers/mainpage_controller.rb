class MainpageController < ApplicationController

  def index


  end

  def get_file_list

    @http = Faraday.new(:url => Videoplayer::Constants::DISK_API_URL) do |builder|
      #builder.use FaradayMiddleware::OAuth, Videoplayer::Constants::YANDEX_TOKEN
      builder.request :authorization, "OAuth", Videoplayer::Constants::YANDEX_TOKEN
      builder.adapter  Faraday.default_adapter
    end

    #responce = @http.get('/v1/disk/resources/last-uploaded')

    video_item = @http.get '/v1/disk/public/resources/download', :public_key => 'gRpITtCZI2Aix34cC8dYUjxb47R0DBkQ8eg0VLVcQjU='
    render json: video_item.body
  end

end
