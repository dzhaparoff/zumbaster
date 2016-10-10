class AddColumnsToModelsWithAttaches < ActiveRecord::Migration
  def change
    add_column :episodes, :screenshot_meta, :text
    add_column :people, :headshot_meta, :text
    add_column :seasons, :poster_meta, :text
    add_column :seasons, :thumb_meta, :text
    add_column :shows, :poster_meta, :text
    add_column :shows, :poster_ru_meta, :text
    add_column :shows, :fanart_meta, :text
    add_column :shows, :logo_meta, :text
    add_column :shows, :clearart_meta, :text
    add_column :shows, :banner_meta, :text
    add_column :shows, :thumb_meta, :text
    add_column :users, :avatar_meta, :text
  end
end
