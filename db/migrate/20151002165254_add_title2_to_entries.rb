class AddTitle2ToEntries < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :sub_title, :string, :default => ''
    add_column :semi_static_entries, :simple_text, :boolean, :default => false
  end
end
