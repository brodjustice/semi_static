ss Misc < ActiveRecord::Migration
  def up
    add_column :semi_static_entries, :unrestricted_html, :boolean, :default => false
    # Move the banner images directory to stop conflict with entries

    Dir.mkdir(Rails.root.to_s + '/public/system/banners') unless File.exists?(Rails.root.to_s + '/public/system/banners')
    SemiStatic::Banner.all.each{|b|
      FileUtils.mv(Rails.root.to_s + "/public/system/imgs/#{b.id.to_s}", Rails.root.to_s + '/public/system/banners')
    }
  end

  def down
    remove_column :semi_static_entries, :unrestricted_html
  end
end
