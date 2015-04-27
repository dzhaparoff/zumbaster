class CreateGenres < ActiveRecord::Migration
  def change
    create_table :genres do |t|
      t.string :name_ru
      t.string :name_en
      t.string :slug_ru
      t.string :slug_en

      t.timestamps
    end

    create_table :genres_shows, id: false do |t|
      t.belongs_to :show, index: true
      t.belongs_to :part, index: true
    end
  end
end
