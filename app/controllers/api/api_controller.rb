class Api::ApiController < ApplicationController
  layout false

  def manifest
    translation = Translation.find params[:id]

    if params[:format] == 'm3u8'
      manifest = translation.manifest :mobile
    else
      manifest = translation.manifest :desktop
    end

    render body: manifest.body
  end
end
