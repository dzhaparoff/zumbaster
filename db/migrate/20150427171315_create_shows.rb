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
end
