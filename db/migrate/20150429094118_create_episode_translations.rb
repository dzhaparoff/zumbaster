class CreateEpisodeTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|
      t.string :translator

      t.string :moonwalk_token
      t.string :f4m
      t.string :m3u8
      t.string :local

      t.datetime :added_at

      t.timestamps
    end
  end
end
