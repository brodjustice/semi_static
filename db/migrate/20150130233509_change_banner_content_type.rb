class ChangeBannerContentType < ActiveRecord::Migration
  def up
    rename_column :semi_static_banners, :img_file_type, :img_content_type
  end

  def down
    rename_column :semi_static_banners, :img_content_type, :img_file_type
  end
end
