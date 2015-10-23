class AddImagePopupToEntry < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :image_popup, :boolean, :default => false
  end
end
