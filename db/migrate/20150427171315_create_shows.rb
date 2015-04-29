class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.string :slug_ru
      t.string :slug_en
      t.string :title_ru
      t.string :title_en
      t.string :description_ru
      t.string :description_en
      t.string :slogan_ru
      t.string :slogan_en

      t.integer :year, index: true

      t.datetime :first_aired
      t.datetime :updated

      t.json :ids
      t.json :airs
      t.integer :runtime
      t.string :certification
      t.string :network, index: true
      t.string :country

      t.string :homepage
      t.string :status
      t.integer :aired_episodes

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
