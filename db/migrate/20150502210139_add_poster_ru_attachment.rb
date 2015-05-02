class AddPosterRuAttachment < ActiveRecord::Migration
    def self.up
      add_attachment :shows, :poster_ru
    end

    def self.down
      remove_attachment :shows, :poster_ru
    end
end
