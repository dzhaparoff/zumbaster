class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authorize_rmp_request

  private

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  # def set_site_title
  #   set_meta_tags site: 'Сериалы в хорошем качестве бесплатно и без рекламы', reverse: true
  # end

  protected

  def has_permissions_to_edit? params
    current_user.present? && (current_user.administrator? || current_user.id == params[:id].to_i)
  end

  def authorize_rmp_request
    Rack::MiniProfiler.authorize_request if current_user && current_user.id == 5
  end
end
