class AddXingShareToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :xing_share, :boolean, :default => false
  end
end