class AddMergedEntryChain < ActiveRecord::Migration[5.2]
  def up
    add_column :semi_static_entries, :merged_id, :integer

    # Clean up some previous mistakes
    remove_column :semi_static_entries, :entries
    remove_column :semi_static_entries, :boolean

    SemiStatic::Entry.reset_column_information
    SemiStatic::Entry.unmerged.each{|main_entry|
      current_entry = main_entry
      main_entry.merged_entries_by_position.each{|merged_entry|
        current_entry.merged_entry = merged_entry
        current_entry.position = main_entry.position
        current_entry.save
        current_entry = merged_entry
      }
    }
  end

  def down
    remove_column :semi_static_entries, :merged_id, :integer

    # Un-clean up some previous mistakes
    add_column :semi_static_entries, :entries
    add_column :semi_static_entries, :boolean

  end
end
