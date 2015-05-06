class AddTranslationReferences < ActiveRecord::Migration
  def change
    add_belongs_to :translations, :episode
    add_belongs_to :translations, :translator
  end
end
