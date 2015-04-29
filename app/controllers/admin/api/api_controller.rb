class Admin::Api::ApiController < Admin::AdminController
  def check
    render json: {'asd'=>'asdf'}
  end
end