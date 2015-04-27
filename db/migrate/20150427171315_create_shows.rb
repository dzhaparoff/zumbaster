class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.string :title_ru
      t.string :title_en
      t.integer :year, index: true
      t.datetime :first_aired
      t.string :description_ru
      t.string :description_en
      t.json :ids
      t.json :airs
      t.integer :runtime
      t.string :certification
      t.string :network, index: true
      t.string :country
      t.datetime :updated_at
      t.string :homepage
      t.string :status
      t.integer :aired_episodes

      t.references :ratings
      t.references :cast_people
      t.references :crew_people
      t.references :seasons
      t.references :episodes

      t.timestamps
    end
  end

  def self.up
    add_attachment :shows, :fanart
    add_attachment :shows, :poster
    add_attachment :shows, :logo
    add_attachment :shows, :clearart
    add_attachment :shows, :banner
    add_attachment :shows, :thumb
  end

  def self.down
    remove_attachment :shows, :fanart
    remove_attachment :shows, :poster
    remove_attachment :shows, :logo
    remove_attachment :shows, :clearart
    remove_attachment :shows, :banner
    remove_attachment :shows, :thumb
  end
end
