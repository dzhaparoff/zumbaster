Rails.application.routes.draw do
  root 'mainpage#index'

  devise_for :users, controllers: {
                       omniauth_callbacks: 'users/omniauth_callbacks',
                       sessions: 'users/sessions'
                   }

  namespace :api do
    get '/:action' => 'api' # non RESTful api
    post '/:action' => 'api' # non RESTful api
  end

  namespace :admin do
    root 'admin#index'

    namespace :api do
      get '/:action' => 'api' # non RESTful api
      post '/:action' => 'api' # non RESTful api
    end
  end

  get '/:show_slug' => 'shows#detail', as: :show
  get '/:show_slug/season-:season_number' => 'shows#season', as: :show_season
  get '/:show_slug/season-:season_number/episode-:episode_number' => 'shows#episode', as: :show_episode
  get '/:show_slug/season-:season_number/episode-:episode_number/translator-:translator_id' => 'shows#episode_translation', as: :show_episode_translation

  get '/genres/:genre_slug' => 'genres#detail', as: :genre
end