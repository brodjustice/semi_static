class AddEntryMergeWithPrevious < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :merge_with_previous, :boolean, :default => false    
  end
end
