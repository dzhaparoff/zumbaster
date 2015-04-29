class CreateCasts < ActiveRecord::Migration
  def change
    create_table :casts do |t|
      t.string :character
      t.references :show
      t.references :person
      t.timestamps
    end
  end
end
