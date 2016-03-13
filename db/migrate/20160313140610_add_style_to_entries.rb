class AddStyleToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :style, :text
  end
end
