class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :slug_ru
      t.string :slug_en
      t.string :name_ru
      t.string :name_ru
      t.string :biography_ru
      t.string :biography_en
      t.date :birthday
      t.date :death
      t.string :birthplace
      t.integer :growth

      t.json :ids

      t.timestamps
    end
  end

  def self.up
    add_attachment :seasons, :headshot
  end

  def self.down
    remove_attachment :seasons, :headshot
  end
end
