class CreateZbRatings < ActiveRecord::Migration
  def change
    create_table :zb_ratings do |t|
      t.references :rating, index: true
      t.decimal :value, scale: 3, precision: 10
      t.integer :count

      t.timestamps
    end
  end
end
