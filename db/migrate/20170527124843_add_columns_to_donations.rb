class AddColumnsToDonations < ActiveRecord::Migration[5.0]
  def change
    change_table :donations do |t|
      t.decimal :amount_payed, precision: 12, scale: 2, default: 0
      t.decimal :amount_cash, precision: 12, scale: 2, default: 0
      t.string :payment_system
    end
  end
end
