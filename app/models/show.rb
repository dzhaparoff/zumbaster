class Show < ActiveRecord::Base
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks

  # index_name "#{Rails.env}_shows"
  #
  # def self.reindex
  #   self.__elasticsearch__.create_index! force: true
  #   self.__elasticsearch__.refresh_index!
  #   self.import
  # end
  #
  # settings index: {
  #     number_of_shards: 1,
  #     number_of_replicas: 0,
  #     analysis: {
  #         analyzer: {
  #             show_analyzer: {
  #                 tokenizer: "standard",
  #                 filter: ["standard", "lowercase", "ru_snowball", "en_snowball"]
  #             }
  #         },
  #         filter: {
  #             ru_snowball: {
  #                 type: "snowball",
  #                 language: "Russian"
  #             },
  #             en_snowball: {
  #                 type: "snowball",
  #                 language: "English"
  #             },
  #         }
  #     }
  # } do
  #   mappings dynamic: 'false' do
  #     indexes :id,             type: 'integer'
  #     indexes :title_ru,       analyzer: 'show_analyzer', type: "text"
  #     indexes :title_en,       analyzer: 'show_analyzer', type: "text"
  #     indexes :description_ru, analyzer: 'show_analyzer', type: "text"
  #     indexes :description_en, analyzer: 'show_analyzer', type: "text"
  #     indexes :slogan_ru,      analyzer: 'show_analyzer', type: "text"
  #     indexes :slogan_en,      analyzer: 'show_analyzer', type: "text"
  #     indexes :network,        analyzer: 'show_analyzer', type: "text"
  #     indexes :country,        analyzer: 'show_analyzer', type: "text"
  #   end
  # end
  #
  # def as_indexed_json(options={})
  #   self.as_json(
  #       only: [:id,
  #              :title_ru,
  #              :title_en,
  #              :description_ru,
  #              :description_en,
  #              :slogan_ru,
  #              :slogan_en,
  #              :network,
  #              :country]
  #   )
  # end


  has_and_belongs_to_many :genres, :join_table => :genres_shows
  has_many :casts
  has_many :crews
  has_one :rating, as: :rated
  has_many :seasons, :dependent => :destroy
  has_many :episodes, :dependent => :destroy

  after_initialize :init

  has_attached_file :poster, :styles => { :medium => "600x900>", :thumb => "300x450>" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :poster_ru, :styles => { :medium => "600x900>", :thumb => "300x450>" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :fanart, :styles => { :medium => "1280x720>", :thumb => "853x480>" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :logo, :styles => { :medium => "400x155", :thumb => "200x75#" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :clearart, :styles => { :medium => "500x250#", :thumb => "250x125#" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :banner, :styles => { :medium => "480x70#" }, convert_options: { all: '-quality 75 -strip' }
  has_attached_file :thumb, :styles => { :medium => "500x281#", :thumb => "250x140#" }, convert_options: { all: '-quality 75 -strip' }

  do_not_validate_attachment_file_type :fanart, :poster, :logo, :clearart, :banner, :thumb

  default_scope do
    where.not(updated: nil)
  end

  scope :waiting_fot_publish, -> {
    unscoped.where(updated: nil)
  }

  scope :waiting_for_update, -> (date) {
    joins(:seasons, :episodes)
        .where("episodes.first_aired > ? AND episodes.first_aired < ? AND NOT (seasons.aired_episodes = seasons.episode_count AND shows.status LIKE 'ended')",
               date.yesterday.beginning_of_day, date.yesterday.end_of_day)
        .select("DISTINCT ON (shows.id) shows.*")
  }

  def self.existed_ids
    shows = unscoped.select :ids

    kp, imdb, tvrage, myshow = [],[],[],[]

    shows.each do |s|
      kp << s.ids['kp']
      imdb << s.ids['imdb']
      tvrage << s.ids['tvrage']
      myshow << s.ids['myshow']
    end

    { kp: kp, imdb: imdb, tvrage: tvrage, myshow: myshow }
  end

  class << self
    def columns_list
       self.column_names
    end
    alias_method :fields, :columns_list
  end

  attr_reader :img

  private

  def init
    @img = poster.url(:thumb)
  end
end
