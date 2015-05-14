class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.string :slug_ru
      t.string :slug_en
      t.string :title_ru
      t.string :title_en
      t.text :description_ru
      t.text :description_en

      t.datetime :first_aired

      t.integer :number
      t.json :ids
      t.integer :episode_count
      t.integer :aired_episodes

      t.references :show

      t.timestamps
    end
  end
end
