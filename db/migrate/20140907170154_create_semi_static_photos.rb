class CreateSemiStaticPhotos < ActiveRecord::Migration
  def change
    create_table :semi_static_photos do |t|
      t.string :title
      t.text :description
      t.boolean :home_page, :default => false
      t.string:img_file_name
      t.string :img_content_type
      t.integer :img_file_size
      t.integer :position, :default => 0
      t.integer :entry_id

      t.timestamps
    end
  end
end
