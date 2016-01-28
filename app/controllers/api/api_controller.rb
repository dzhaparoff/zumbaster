class Api::ApiController < ApplicationController
  layout false

  def manifest
    translation = Translation.find params[:id]

    if params[:format] == 'm3u8'
      manifest = translation.manifest :mobile
      type = 'application/vnd.apple.mpegurl; charset=utf-8'
      send_data manifest.body, format: type
    else
      create_f4m_file translation
    end
  end

  private
  def create_f4m_file translation
    manifest = translation.manifest :desktop
    manifest = Nokogiri::XML manifest.body
    manifest.css("media").each do |media|
      media['url'] = media['url'].gsub(/http:\/\//,'/stream/f4m/')
    end
    send_data manifest.to_xml, format: 'application/xml; charset=utf-8'
  end
end
