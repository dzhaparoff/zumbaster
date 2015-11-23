class Seo < ActiveRecord::Base
  belongs_to :meta, polymorphic: true

  # self.column :description, :text, limit: 250


end
