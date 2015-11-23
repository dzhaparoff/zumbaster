class Genre < ActiveRecord::Base

  after_save do
    Seo.find_or_create_by meta: self if self.seo.nil?
  end

  has_and_belongs_to_many :shows, :join_table => :genres_shows
  has_one :seo, as: :meta, dependent: :destroy

end
