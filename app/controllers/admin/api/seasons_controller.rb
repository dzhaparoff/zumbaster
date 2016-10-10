class Admin::Api::SeasonsController < Admin::Api::ApiController
  def index
    @items = Season.order('id asc').all
  end

  def new
    @item = Season.new
  end

  def create
    @item = Season.create(model_params)
    render action: :show
  end

  def show
    @item = Season.find(params[:id])
  rescue
    not_found
  end

  def edit
     @item = Season.find(params[:id])
  rescue
    not_found
  end

  def update
    @item = Season.find(params[:id])
    @item.update(model_params)
    render action: :show
  end

  def destroy
    @item = Season.find(params[:id])
    @item.destroy
    render action: :show
  end

  private

  def model_params
    params
       .permit(
          :slug_ru, :slug_en, :title_ru, :title_en, :description_ru, :description_en, :first_aired, :number, :ids, :episode_count, :aired_episodes, :show_id, :created_at, :updated_at, :poster_file_name, :poster_content_type, :poster_file_size, :poster_updated_at, :thumb_file_name, :thumb_content_type, :thumb_file_size, :thumb_updated_at, :poster_meta, :thumb_meta
       )
   end
end
