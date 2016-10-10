class Seo < ActiveRecord::Base
  belongs_to :meta, polymorphic: true

  # self.column :description, :text, limit: 250
  cattr_reader :columns_list do
    self.column_names
  end
  cattr_reader :fields do
    self.column_names
  end

end
