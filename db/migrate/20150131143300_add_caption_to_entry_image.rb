class AddCaptionToEntryImage < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :image_caption, :text
  end
end
