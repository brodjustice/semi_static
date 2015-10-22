class AddImgDimensionsToPhoto < ActiveRecord::Migration
  def change
    add_column :semi_static_photos, :img_dimensions, :string
    add_column :semi_static_photos, :popup, :boolean, :default => false
  end
end
