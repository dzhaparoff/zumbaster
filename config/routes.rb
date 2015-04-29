Rails.application.routes.draw do
  root 'mainpage#index'

  namespace :admin do
    root 'admin#index'

    namespace :api do
      get '/:action' => 'api' # non RESTful api
      post '/:action' => 'api' # non RESTful api
    end
  end
end
