class AddLayoutSelectToTagsAndEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_tags, :layout_select, :integer
    add_column :semi_static_entries, :layout_select, :integer
  end
end
