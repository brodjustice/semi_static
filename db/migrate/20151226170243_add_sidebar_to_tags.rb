class AddSidebarToTags < ActiveRecord::Migration
  def change
    add_column :semi_static_tags, :sidebar_id, :integer, :default => nil
  end
end
