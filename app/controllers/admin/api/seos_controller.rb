class Admin::Api::SeosController < Admin::Api::ApiController
  def index
    render json: {}
  end

  def new
    @seo = Seo.new
  end

  def create

  end

  def show
    @seo = Seo.where(id: params[:id]).first
    @seo = Seo.new(id: params[:id]) if @seo.nil?
  end

  def edit

  end

  def update
    render json: Seo.find(params[:id]).update(model_params)
  rescue
    not_found
  end

  def destroy

  end

  private

  def model_params
    params
        .permit(
            :title,
            :description,
            :robots
        )
  end

end
