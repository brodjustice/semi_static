class AddLinkedinShareToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :linkedin_share, :boolean, :default => false
  end
end
