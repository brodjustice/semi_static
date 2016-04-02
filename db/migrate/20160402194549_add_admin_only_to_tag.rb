class AddAdminOnlyToTag < ActiveRecord::Migration
  def change
    add_column :semi_static_tags, :admin_only, :boolean, :default => false
  end
end
