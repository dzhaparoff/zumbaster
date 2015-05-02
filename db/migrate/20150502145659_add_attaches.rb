class AddAttaches < ActiveRecord::Migration
  def self.up
    add_attachment :shows, :fanart
    add_attachment :shows, :poster
    add_attachment :shows, :logo
    add_attachment :shows, :clearart
    add_attachment :shows, :banner
    add_attachment :shows, :thumb

    add_attachment :seasons, :poster
    add_attachment :seasons, :thumb

    add_attachment :seasons, :screenshot

    add_attachment :seasons, :headshot
  end

  def self.down
    remove_attachment :shows, :fanart
    remove_attachment :shows, :poster
    remove_attachment :shows, :logo
    remove_attachment :shows, :clearart
    remove_attachment :shows, :banner
    remove_attachment :shows, :thumb

    remove_attachment :seasons, :poster
    remove_attachment :seasons, :thumb

    remove_attachment :seasons, :screenshot

    remove_attachment :seasons, :headshot
  end
end
