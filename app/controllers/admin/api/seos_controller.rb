class Admin::Api::SeosController < Admin::Api::ApiController
  def index
    render json: {}
  end

  def new

  end

  def create

  end

  def show
    @seo = Seo.find(params[:id])
  end

  def edit

  end

  def update
    render json: Seo.find(params[:id]).update(model_params)
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
