class CreateSemiStaticBanners < ActiveRecord::Migration
  def change
    create_table :semi_static_banners do |t|
      t.string :name, :default => nil
      t.string :tag_line, :default => nil

      # Banner Image
      t.string :img_file_name
      t.string :img_file_type
      t.integer :img_file_size

      t.timestamps
    end
    add_column :semi_static_entries, :banner_id, :integer
    add_column :semi_static_tags, :banner_id, :integer
  end
end
