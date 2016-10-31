class Admin::Api::PshowsController < Admin::Api::ApiController
  def index
    @items = Show.waiting_fot_publish.order('id asc').all
  end

  def new
    render json: {}
  end

  def create
    show = model_params
    show.merge! @myshow.get_show model_params[:id]

    new_show = Show.new do |s|
      ids = {
          kp: show['kinopoiskId'],
          imdb: show['imdbId'],
          tvrage: show['tvrageId'],
          myshow: show['id']
      }
      s.slug_ru = show['ruTitle'].parameterize unless show['ruTitle'].nil?
      s.slug_en = show['title'].parameterize unless show['title'].nil?
      s.title_ru = show['ruTitle']
      s.title_en = show['title']
      s.description_ru = show['description']
      s.year = show['year']
      s.ids = ids
      s.runtime = show['runtime']
      s.status = show['status']
    end
    new_show.save

    @item = new_show
    render action: :show
  end

  def show
    @item = Show.unscoped.find(params[:id])
  rescue
    not_found
  end

  def edit

  end

  def update
    show = Show.unscoped.find(params[:id])

    if params[:ids].present? && params[:ids].size > 0
      show.update(ids: params[:ids])
    end

    show.update(model_params)
    @item = show
    render action: :show
  end

  def destroy
    show = Show.unscoped.find(params[:id])
    show.destroy
    render json: { deleted: true }
  end

  ### non restful

  def search_in_myshow
    shows = @myshow.find_show(params[:name])
    return render json: [] if shows.size == 0

    existing_ids = Show.existed_ids
    shows.values.each do |show|
      show['exist'] = true if existing_ids[:myshow].include? show['id'].to_i
    end
    render json: shows.values
  end

  def sync_ids
    show = Show.unscoped.find(params[:id])
    @item = show.sync_ids
    render action: :show, formats: :json
  end

  def sync_with_trakt
    show = Show.unscoped.find(params[:id])
    @item = show.sync_with_trakt
    render action: :show, formats: :json
  end

  def sync_meta
    show = Show.unscoped.find(params[:id])
    @item = show.sync_meta
    render action: :show, formats: :json
  end

  def sync_with_tmdb
    show = Show.unscoped.find(params[:id])
    @item = show.sync_with_tmdb
    render action: :show, formats: :json
  end

  def sync_with_fanart
    show  = Show.unscoped.find(params[:id])
    @item = show.sync_with_fanart
    render action: :show, formats: :json
  end

  def sync_translate
    show  = Show.unscoped.find(params[:id])
    @item = show.sync_translate
    render action: :show, formats: :json
  end

  def sync_pics
    show  = Show.unscoped.find(params[:id])
    @item = show.sync_pics
    render action: :show, formats: :json
  end

  def sync_rating
    show = Show.unscoped.find(params[:id])
    @item = show.sync_rating
    render action: :show, formats: :json
  end


  def sync_people

    show = Show.unscoped.find(params[:id])

    if show.ids['kp'].to_i == 0
      return render json: show
    end
    #
    # imdb = imdb_to_trakt_id show.ids['imdb']
    # people = @trakt.show_people imdb
    #
    # people['cast'].each do |c|
    #   person = Person.where(slug_en: c['person']['ids']['slug']).first_or_create
    #   cast = show.casts.where(character: c['character'], person: person, show: show).first_or_create
    #   person.name_en = c['person']['name']
    #   person.slug_en = c['person']['ids']['slug']
    #   person.biography_en = c['person']['biography']
    #   person.birthday = Date.parse c['person']['birthday'] unless c['person']['birthday'].nil?
    #   person.death = Date.parse c['person']['death'] unless c['person']['death'].nil?
    #   person.ids = c['person']['ids']
    #   person.headshot = c['person']['images']['headshot']['full'] unless c['person']['images']['headshot']['full'].nil? || person.headshot.exists?
    #   person.save
    #   cast.save
    #   show.casts << cast
    # end unless people['cast'].nil?
    #
    # people['crew'].each do |key, group|
    #   group.each do |c|
    #     person = Person.where(slug_en: c['person']['ids']['slug']).first_or_create
    #     crew = show.crews.where(job: c['job'], person: person, show: show).first_or_create
    #     person.name_en = c['person']['name']
    #     person.slug_en = c['person']['ids']['slug']
    #     person.biography_en = c['person']['biography']
    #     person.birthday = Date.parse c['person']['birthday'] unless c['person']['birthday'].nil?
    #     person.death = Date.parse c['person']['death'] unless c['person']['death'].nil?
    #     person.ids = c['person']['ids']
    #     person.headshot = c['person']['images']['headshot']['full'] unless c['person']['images']['headshot']['full'].nil? || person.headshot.exists?
    #     person.save
    #     crew.job_group = key
    #     crew.save
    #     show.crews << crew
    #   end
    # end unless people['crew'].nil?
    #
    # show.save

    @item = show
    render action: :show, formats: :json
  end


  def activate
    show = Show.unscoped.find(params[:id])
    @item = show.activate
    render action: :show, formats: :json
  end

  def sync_seasons
    show = Show.unscoped.find params[:id]
    job = Delayed::Job.enqueue SyncAllSeasonsJob.new(show)
    render json: {
               model: show,
               job: job
           }
  end

  def sync_videos
    show = Show.unscoped.find(params[:id])
    @item = show.sync_videos
    render action: :show, formats: :json
  end

  def sync_ru_names
    show = Show.unscoped.find(params[:id])
    @item = show.sync_ru_names
    render action: :show, formats: :json
  end

  ### end

  private

  def model_params
    params
        .permit(
            :country,
            :slug_ru,
            :slug_en,
            :description,
            :description_ru,
            :description_en,
            :slogan_ru,
            :slogan_en,
            :ended,
            :id,
            :ids,
            :imdbId,
            :kinopoiskId,
            :rating,
            :ruTitle,
            :title,
            :runtime,
            :started,
            :status,
            :tvrageId,
            :year
        )
  end
end
