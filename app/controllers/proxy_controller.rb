class ProxyController < ApplicationController
  layout false

  def stream_f4m
    send_data Faraday.new(url: "http://#{params[:host]}").get("/sec/#{params[:address]}").body
  end
  def stream_m3u8
    send_data Faraday.new(url: "http://#{params[:host]}").get("/sec/#{params[:address]}").body
  end
end
