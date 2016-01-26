class AddTwitterShareToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :twitter_share, :boolean, :default => :false
  end
end
