class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :rated, polymorphic: true, index: true
      t.references :imdb_rating, index: true
      t.references :kp_rating, index: true
      t.references :zb_rating, index: true

      t.timestamps
    end
  end
end