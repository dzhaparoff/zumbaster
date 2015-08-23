class Admin::AdminController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!, :user_is_admin?
  skip_before_action :verify_authenticity_token

  def index
    @shows = Show.all
  end

  private

  def user_is_admin?
    redirect_to :root if current_user.email != 'd_enver@mail.ru' && user_signed_in?
  end
end
