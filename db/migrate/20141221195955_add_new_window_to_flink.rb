class AddNewWindowToFlink < ActiveRecord::Migration
  def change
    add_column :semi_static_links, :new_window, :boolean, :default => false
  end
end
