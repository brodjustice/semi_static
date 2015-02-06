class AddRawHtmlToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :raw_html, :boolean, :default => false
  end
end
