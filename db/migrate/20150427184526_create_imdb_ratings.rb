class CreateImdbRatings < ActiveRecord::Migration
  def change
    create_table :imdb_ratings do |t|
      t.references :rating, index: true
      t.decimal :value, scale: 3, precision: 10
      t.integer :count

      t.timestamps
    end
  end
end
