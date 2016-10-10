class AddSubtitlesColumnToTranslation < ActiveRecord::Migration[5.0]
  def change
    change_table :translations do |t|
      t.string :subtitles, default: ""
    end
  end
end
