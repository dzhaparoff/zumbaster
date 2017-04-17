class CreateDonations < ActiveRecord::Migration[5.0]
  def change
    create_table :donations do |t|
      t.string :ex_id, index: true
      t.string :name
      t.string :amount
      t.string :comment

      t.datetime :donation_date
      
      t.timestamps
    end
  end
end
