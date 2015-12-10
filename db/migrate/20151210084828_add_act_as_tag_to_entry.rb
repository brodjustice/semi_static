class AddActAsTagToEntry < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :acts_as_tag_id, :integer, :default => nil
  end
end
