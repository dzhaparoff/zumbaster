class Admin::ShowsController < Admin::AdminController

    def index
        @shows = Show.order('id asc').all
    end

    def new

    end

    def show
      @show = Show.find params['id']
      @seasons = @show.seasons.order :number
    end

    def pending
      @shows = Show.unscoped.where(updated: nil)
    end
end
