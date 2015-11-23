class Admin::Api::GenresController < Admin::Api::ApiController
  def index
    @genres = Genre.order('id asc').all
  end

  def new

  end

  def create

  end

  def show
    @genre = Genre.find(params[:id])
    check_seo @genre
  end

  def edit

  end

  def update
    render json: Genre.find(params[:id]).update(model_params)
  end

  def destroy

  end

  private

  def check_seo item
    Seo.find_or_create_by meta: item if item.seo.nil?
  end

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
