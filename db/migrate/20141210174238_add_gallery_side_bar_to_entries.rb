class AddGallerySideBarToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :side_bar_gallery, :integer, :default => 0
  end
end
