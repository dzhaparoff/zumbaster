class Admin::Api::ShowsController < Admin::Api::ApiController
  def index
    @items = Show.order('id asc').all
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

    render json: new_show
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
    unless params[:ids].nil? && params[:ids].size > 0
      show.ids = params[:ids]
      show.save
    end
    render json: show.update(model_params)
  end

  def destroy
    show = Show.unscoped.find(params[:id])
    show.destroy
    render json: { deleted: true }
  end

  ### non restful

  def deactivate
    show = Show.unscoped.find(params[:id])
    show.updated = nil
    show.save
    sleep 0.5
    render json: show
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

    if show.ids['kp'].to_i == 0
      return render json: show
    end

    kp = show.ids['kp']

    moonwalk = @moonwalk.show kp

    moonwalk.each do |m|
      translator_id = m['translator_id']
      moonwalk_episodes = @moonwalk.get_playlist_url_parallel kp, translator_id
      moonwalk_episodes[:playlists].each_pair do |season_number, episodes|
        episodes.each_pair do |episode_number, playlists|
          episode = Episode.where(show: show, abs_name: "#{season_number.to_i}-#{episode_number.to_i}").take
          translator = Translator.where(ex_id: translator_id).take
          translation = Translation.where(episode: episode, translator: translator).first_or_create
          translation.moonwalk_token = playlists['token'] unless translation.moonwalk_token == 'temp_token'
          translation.save
        end
      end
    end

    render json: show
  end

  def sync_ru_names
    show = Show.unscoped.find(params[:id])

    if show.ids['kp'].to_i == 0
      return render json: show
    end

    kp = show.ids['kp']
    kp_episode_names = @kinopoisk.episode_names kp
    show.episodes.each do |episode|
      title_en = episode.title_en
      next if title_en.nil?
      next if title_en.size < 2
      kp_episode_names.each do |key, value|
        next unless value.size > 0
        regexp = Regexp.new("#{title_en}", Regexp::IGNORECASE)
        if key.length > 1
          regexp2 = Regexp.new("#{key}", Regexp::IGNORECASE)
        else
          regexp2 = key
        end
        if key[regexp] || title_en[regexp2]
          episode.title_ru = value
          episode.title_en = key
        end
      end
      episode.save
    end

    render json: show
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
