class Api::SearchController < Api::ApiController
  def show
    @shows = Show.search_by_name(params[:id])
    render json: {result: @shows}
  end
end