Rails.application.routes.draw do
  root 'mainpage#index'

  # Authentication
  devise_for :users, skip: [:sessions, :passwords, :confirmations, :registrations],
             controllers: {
                       omniauth_callbacks: 'users/omniauth_callbacks'
             }
  as :user do
    # session handling
    get     '/login'  => 'users/sessions#new',     as: 'new_user_session'
    post    '/login'  => 'users/sessions#create',  as: 'user_session'
    delete  '/logout' => 'users/sessions#destroy', as: 'destroy_user_session'

    # joining
    get   '/registration' => 'users/registrations#new',    as: 'new_user_registration'
    post  '/registration' => 'users/registrations#create', as: 'user_registration'

    scope '/account' do
      # password reset
      get   '/reset-password'        => 'users/passwords#new',    as: 'new_user_password'
      put   '/reset-password'        => 'users/passwords#update', as: 'user_password'
      post  '/reset-password'        => 'users/passwords#create'
      get   '/reset-password/change' => 'users/passwords#edit',   as: 'edit_user_password'

      # confirmation
      get   '/confirm'        => 'users/confirmations#show',   as: 'user_confirmation'
      post  '/confirm'        => 'users/confirmations#create'
      get   '/confirm/resend' => 'users/confirmations#new',    as: 'new_user_confirmation'

      # settings & cancellation
      get '/cancel'   => 'users/registrations#cancel', as: 'cancel_user_registration'
      get '/settings' => 'users/registrations#edit',   as: 'edit_user_registration'
      put '/settings' => 'users/registrations#update'

      # account deletion
      delete '' => 'users/registrations#destroy'
    end
  end
  # auth end

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