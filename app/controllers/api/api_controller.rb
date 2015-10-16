class Api::ApiController < ApplicationController
  def player_playlists_for
    translation = Translation.find params[:id]

    unless translation.translation_video_exist?
      translation.sync_translation_video
    end

    render json: {
               f4m: translation.f4m,
               m3u8: translation.m3u8,
               token: translation.monwalk_token
           }
  end
end
