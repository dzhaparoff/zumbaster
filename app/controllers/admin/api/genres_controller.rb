class Admin::Api::GenresController < Admin::Api::ApiController
  def index
    render json: Genre.order('id asc').all
  end

  def new

  end

  def create

  end

  def show
    render json: Genre.find(params[:id])
  end

  def edit

  end

  def update
    render json: Genre.find(params[:id]).update(model_params)
  end

  def destroy

  end

  private

  def model_params
    params
        .permit(
            :name_ru,
            :name_en,
            :slug_ru,
            :slug_en
        )
  end

end
