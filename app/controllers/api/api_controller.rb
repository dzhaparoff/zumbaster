class Api::ApiController < ApplicationController
  layout false

  def manifest
    translation = Translation.find params[:id]

    if params[:format] == 'm3u8'
      manifest = translation.manifest :mobile
      type = 'application/vnd.apple.mpegurl; charset=utf-8'
    else
      manifest = translation.manifest :desktop
      type = 'application/xml; charset=utf-8'
    end

    send_data manifest.body, type: type
  end
end
