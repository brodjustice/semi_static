class AddEntryGalleryControl < ActiveRecord::Migration
  def up
    add_column :semi_static_photos, :gallery_control, :integer, :default => 0
  end

  def down
    remove_column :semi_static_photos, :gallery_control
  end
end
