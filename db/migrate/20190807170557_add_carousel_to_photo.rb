class AddCarouselToPhoto < ActiveRecord::Migration[5.2]
  def change
    add_column :semi_static_photos, :carousel, :boolean
  end
end
