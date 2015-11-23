class CreateSeos < ActiveRecord::Migration
  def change
    create_table :seos do |t|
      t.string  :title, limit: 75
      t.string  :description, limit: 255
      t.string  :robots
      t.references :meta, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
