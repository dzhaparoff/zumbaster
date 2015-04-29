class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.string :slug_ru
      t.string :slug_en
      t.string :title_ru
      t.string :title_en
      t.string :description_ru
      t.string :description_en

      t.datetime :first_aired

      t.integer :number
      t.json :ids
      t.integer :episode_count
      t.integer :aired_episodes

      t.references :show
      t.references :rating

      t.timestamps
    end
  end

  def self.up
    add_attachment :seasons, :poster
    add_attachment :seasons, :thumb
  end

  def self.down
    remove_attachment :seasons, :poster
    remove_attachment :seasons, :thumb
  end
end
