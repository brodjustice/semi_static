class AddTagLinkToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :link_to_tag, :boolean, :default => false
  end
end
