class AddAttaches < ActiveRecord::Migration
  def self.up
    add_attachment :shows, :fanart
    add_attachment :shows, :poster
    add_attachment :shows, :logo
    add_attachment :shows, :clearart
    add_attachment :shows, :banner
    add_attachment :shows, :thumb
    add_attachment :shows, :poster_ru

    add_attachment :seasons, :poster
    add_attachment :seasons, :thumb

    add_attachment :episodes, :screenshot

    add_attachment :people, :headshot
  end

  def self.down
    remove_attachment :shows, :fanart
    remove_attachment :shows, :poster
    remove_attachment :shows, :logo
    remove_attachment :shows, :clearart
    remove_attachment :shows, :banner
    remove_attachment :shows, :thumb
    remove_attachment :shows, :poster_ru

    remove_attachment :seasons, :poster
    remove_attachment :seasons, :thumb

    remove_attachment :episodes, :screenshot

    remove_attachment :people, :headshot
  end
end
