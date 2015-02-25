class AddNewsPhotoToEntry < ActiveRecord::Migration
  def self.up
    add_attachment :semi_static_entries, :news_img
  end
  def self.down
    remove_attachment :semi_static_entries, :news_img
  end
end
