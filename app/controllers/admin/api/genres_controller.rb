class Admin::Api::GenresController < Admin::Api::ApiController
  def index
    @items = Genre.order('id asc').all
  end

  def new
    @item = Genre.new
  end

  def create
    @item = Genre.create(model_params)
    unless params[:seo].nil?
      @item.seo.title = params[:seo][:title]
      @item.seo.description = params[:seo][:description]
      @item.seo.robots = params[:seo][:robots]
      @item.seo.save
    end
    render action: :show
  end

  def show
    @item = Genre.find(params[:id])
  rescue
    not_found
  end

  def edit
    @item = Genre.find(params[:id])
  rescue
    not_found
  end

  def update
    @item = Genre.find(params[:id])
    @item.update(model_params)
    unless params[:seo].nil?
      @item.seo.title = params[:seo][:title]
      @item.seo.description = params[:seo][:description]
      @item.seo.robots = params[:seo][:robots]
      @item.seo.save
    end
    render action: :show
  end

  def destroy
    @item = Genre.find(params[:id])
    @item.destroy
    render action: :show
  end

  private

  def model_params
    params
       .permit(
          :name_ru, :name_en, :slug_ru, :slug_en, :created_at, :updated_at
       )
   end
end
