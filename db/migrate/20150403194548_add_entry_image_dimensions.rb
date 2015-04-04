class AddEntryImageDimensions < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :img_dimensions, :string
  end
end
