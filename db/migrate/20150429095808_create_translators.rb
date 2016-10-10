class CreateTranslators < ActiveRecord::Migration
  def change
    create_table :translators do |t|
      t.string :name
      t.integer :ex_id

      t.timestamps
    end
  end
end
