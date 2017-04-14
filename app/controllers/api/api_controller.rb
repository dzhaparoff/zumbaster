class Api::ApiController < ApplicationController
  layout false

  def manifest
    translation = Translation.find params[:id]
    if params[:format] == 'm3u8'
      create_m3u8_file translation
    else
      create_f4m_file translation
    end
  end

  private
  def create_f4m_file translation
    manifest = translation.manifest :desktop
    manifest = Nokogiri::XML manifest.body
    manifest.css("media").each do |media|
      media['url'] = media['url'].gsub(/http:\/\//,'/stream/')
    end if Rails.env.production? && false
    send_data manifest.to_xml, format: 'application/xml; charset=utf-8'
  end

  private
  def create_m3u8_file translation
    manifest = translation.manifest(:mobile).body
    manifest.gsub!(/http:\/\//, '/stream/')  if Rails.env.production?
    send_data manifest, format: 'application/vnd.apple.mpegurl; charset=utf-8'
  end
end
