class AddPartialToTagsAndEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :partial, :string, :default => ''
    add_column :semi_static_entries, :entry_position, :integer, :default => SemiStatic::Entry::DISPLAY_ENTRY_SYM[:after]
    add_column :semi_static_tags, :partial, :string, :default => ''
    add_column :semi_static_tags, :entry_position, :integer, :default => SemiStatic::Entry::DISPLAY_ENTRY_SYM[:after]
  end
end
