class AddEntryImageDisable < ActiveRecord::Migration
  def up
    add_column :semi_static_entries, :image_disable, :boolean, :default => false
  end

  def down
    remove_column :semi_static_entries, :image_disable
  end
end
