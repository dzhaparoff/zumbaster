class Admin::AdminController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!, :user_is_admin?, :set_site_title

  def index
    @user = current_user
  end

  def partials
    prefix = construct_prefix params

    template_name = prefix + params[:partial_name]

    if template_exists?(template_name)
      render template: template_name, :layout => false
    else
      render plain: "template not found #{template_name}", :layout => false, :status => 404
    end
  end

  protected

  def json_request?
    request.format.json?
  end

  private

  def user_is_admin?
    #redirect_to :root if !current_user.administrator? && user_signed_in?
  end

  def construct_prefix params
    if params[:partial_suffix] == 'directive'
      prefix = "/admin/partials/ng/directives/"
    else
      prefix = "/admin/partials/ng/" + ( params[:model].nil? ? "" : "#{params[:model]}/" )
    end

    prefix
  end

  def set_site_title
    set_meta_tags site: 'Inanomo', reverse: true
  end
end
