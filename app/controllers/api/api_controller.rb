class Api::ApiController < ApplicationController
  def player_playlists_for
    translation = Translation.find params[:id]
    render json: {
               f4m: translation.f4m,
               m3u8: translation.m3u8
           }
  end
end
