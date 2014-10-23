class AddMasterEntryToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :master_entry_id, :integer
  end
end
