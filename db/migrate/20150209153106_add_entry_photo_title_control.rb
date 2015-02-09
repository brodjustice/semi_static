class AddEntryPhotoTitleControl < ActiveRecord::Migration
  def up
    add_column :semi_static_entries, :show_image_titles, :boolean, :default => false
  end

  def down
    remove_column :semi_static_entries, :show_image_titles
  end
end
