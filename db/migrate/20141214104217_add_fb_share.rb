class AddFbShare < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :facebook_share, :boolean, :default => false
  end
end
