class AddUseAsIndexToTags < ActiveRecord::Migration
  def change
    add_column :semi_static_tags, :use_entry_as_index_id, :integer, :default => nil
  end
end
