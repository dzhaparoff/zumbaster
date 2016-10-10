class AddExpiresMartToTranslation < ActiveRecord::Migration
  def change
    change_table :translations do |t|
      t.integer :expires, default: 0
    end
  end

  def self.up
    Translation.all.each do |translation|
      translation.expires = 0
      translation.save
    end
  end
end
