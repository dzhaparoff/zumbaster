class NewColumnsToShow < ActiveRecord::Migration[5.0]
  def change
    remove_attachment :shows, :logo
    remove_attachment :shows, :clearart

    add_column :shows, :trakt_data, :json
    add_column :shows, :tmdb_data, :json
    add_column :shows, :tmdb_images, :json
    add_column :shows, :fanart_images, :json

    add_column :seasons, :trakt_data, :json
    add_column :seasons, :tmdb_data, :json
    add_column :seasons, :tmdb_images, :json
    add_column :seasons, :fanart_images, :json

    add_column :episodes, :trakt_data, :json
    add_column :episodes, :tmdb_data, :json
    add_column :episodes, :tmdb_images, :json
    add_column :episodes, :fanart_images, :json
  end
end
