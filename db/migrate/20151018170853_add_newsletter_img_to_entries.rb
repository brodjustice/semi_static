class AddNewsletterImgToEntries < ActiveRecord::Migration
  def self.up
    add_attachment :semi_static_entries, :newsletter_img
  end
  def self.down
    remove_attachment :semi_static_entries, :newsletter_img
  end
end
