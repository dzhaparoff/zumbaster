class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :rated, polymorphic: true, index: true

      t.timestamps
    end
  end
end