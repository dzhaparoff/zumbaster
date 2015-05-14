class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :slug_ru
      t.string :slug_en
      t.string :name_ru
      t.string :name_en
      t.text :biography_ru
      t.text :biography_en
      t.date :birthday
      t.date :death
      t.string :birthplace
      t.integer :growth

      t.json :ids

      t.timestamps
    end
  end

end
