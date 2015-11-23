class Admin::AdminController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!, :user_is_admin?, :prepare_globals
  skip_before_action :verify_authenticity_token

  def index
    @user = current_user
  end

  def partials
    if params[:partial_suffix] == 'directive'
      prefix = @ng_partials_directives_path
    else
      prefix = @ng_partials_path
    end

    template_name = prefix + params[:partial_name]

    if template_exists?(template_name)
      render template: template_name, :layout => false
    else
      render plain: "template not found #{template_name}", :layout => false, :status => 404
    end
  end

  private

  def user_is_admin?
    redirect_to :root if current_user.email != 'd_enver@mail.ru' && user_signed_in?
  end

  def prepare_globals
    @ng_partials_path = "/admin/partials/ng/"
    @ng_partials_directives_path = "/admin/partials/ng/directives/"
  end
end
