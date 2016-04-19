class Episode < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks


  has_one :rating, as: :rated
  has_many :translations, :dependent => :destroy
  belongs_to :show
  belongs_to :season

  before_destroy :destroy_rating

  has_attached_file :screenshot,:styles => { :thumb => "400x225#" }, convert_options: { all: '-quality 75 -strip' }

  do_not_validate_attachment_file_type :screenshot

  scope :for_date, -> (date) {
    joins(:season, :show)
        .where("episodes.first_aired > ? AND episodes.first_aired < ? AND NOT (seasons.aired_episodes = seasons.episode_count AND shows.status LIKE 'ended')",
                                date.yesterday.beginning_of_day, date.yesterday.end_of_day)
        .order("episodes.first_aired")
  }

  scope :prev, -> {
    where(:number => number - 1)
  }

  scope :next, -> {
    where(:number => number + 1)
  }

  def prev
    self.class.where(show: show, season: season, :number => number - 1).take
  end

  def next
    self.class.where(show: show, season: season, :number => number + 1).take
  end

  def translations_list
    ids = []
    translations.each do |t|
      ids << t.id unless t.nil?
    end
    ids
  end

  def translators_list
    ids = []
    translations.each do |t|
      ids << t.translator.id unless t.translator.nil?
    end
    ids.sort!
  end

  private

  def destroy_rating
    Rating.delete_all rated: id
  end
end
