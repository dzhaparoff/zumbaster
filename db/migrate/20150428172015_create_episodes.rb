class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.string :slug_ru
      t.string :slug_en
      t.string :title_ru
      t.string :title_en
      t.text :description_ru
      t.text :description_en
      t.string :abs_name

      t.integer :number
      t.integer :number_abs
      t.json :ids

      t.datetime :first_aired
      t.datetime :air_date

      t.references :show
      t.references :season

      t.timestamps
    end
  end

end
