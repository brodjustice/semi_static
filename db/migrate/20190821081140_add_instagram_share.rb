class AddInstagramShare < ActiveRecord::Migration[5.2]
  def change
    add_column :semi_static_entries, :instagram_share, :boolean, :default => false
  end
end
