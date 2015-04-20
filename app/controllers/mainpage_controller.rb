class MainpageController < ApplicationController

  def index
    http = new_http_request_builder

    video2 = http.get('/v1/disk/resources/download', path: 'Сериалы/Теория большого взрыва/s01/e01.mp4')
    @video2 = JSON.parse(video2.body)
  end

  def login
    @http = Faraday.new(:url => 'https://oauth.yandex.ru') do |builder|
      builder.request :authorization, 'OAuth', Videoplayer::Constants::YANDEX_TOKEN
      builder.adapter  Faraday.default_adapter
    end

    responce = @http.post '/authorize?response_type=code',
                          URI.encode_www_form(client_id: 'f04cb3107650479e9c7c05fc70a1f256')

    render html: responce.body

  end

  def get_file_list

    @http = new_http_request_builder

    file_name = '/tmp/' + 'video' + '.flv'
    pl_request = Faraday.new(:url => 'http://kinogo.net')
                        .get('/playlist/sverhestestvennoe-10-sezon.txt')

    pl = pl_request.body

    ctx = V8::Context.new

    playlist_obj = ctx.eval("order = #{pl}")

    file = playlist_obj.playlist['0'].file

    @file = file

    unless File.exist?('public' + file_name)
      open('public' + file_name, 'wb') do |f|
        source = Faraday.new.get(file)
        f << source.body
      end
    end

    movie = FFMPEG::Movie.new('public' + file_name)
    movie.screenshot('public/tmp/' + "screenshot.png", {seek_time: 25, resolution: '320x240'}, preserve_aspect_ratio: :width)
    movie.transcode('public/tmp/' + "video.mp4") { |progress| puts progress }

  end

  private

  def new_http_request_builder
    http = Faraday.new(:url => Videoplayer::Constants::DISK_API_URL) do |builder|
      builder.request :authorization, 'OAuth', Videoplayer::Constants::YANDEX_TOKEN
      builder.adapter  Faraday.default_adapter
    end
  end

end
