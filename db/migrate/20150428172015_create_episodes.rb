class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.string :slug_ru
      t.string :slug_en
      t.string :title_ru
      t.string :title_en
      t.string :description_ru
      t.string :description_en
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

  def self.up
    add_attachment :seasons, :screenshot
  end

  def self.down
    remove_attachment :seasons, :screenshot
  end
end
