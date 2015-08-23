class Admin::GenresController < Admin::AdminController

  def index
    @genres = Genre.order('id asc').all
  end

end
