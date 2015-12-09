class AddAltTitleToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :alt_title, :string, :default => ''
  end
end
