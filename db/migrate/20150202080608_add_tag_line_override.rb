class AddTagLineOverride < ActiveRecord::Migration
  def up
    add_column :semi_static_tags, :tag_line, :string, :default => nil
    add_column :semi_static_entries, :tag_line, :string, :default => nil
  end

  def down
    remove_column :semi_static_tags, :tag_line
    remove_column :semi_static_entries, :tag_line
  end
end
