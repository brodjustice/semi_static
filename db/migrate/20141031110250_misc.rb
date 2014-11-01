class Misc < ActiveRecord::Migration
  def up
    add_column :semi_static_entries, :unrestricted_html, :boolean, :default => false
    # Move the banner images directory to stop conflict with entries

    puts('Creating new directory for banners')
    Dir.mkdir(Rails.root.to_s + '/public/system/banners') unless File.exists?(Rails.root.to_s + '/public/system/banners')
    SemiStatic::Banner.all.each{|b|
      unless File.exists?(Rails.root.to_s + "/public/system/banners/#{b.id.to_s}")
        puts 'Copy from: ' + Rails.root.to_s + "/public/system/imgs/#{b.id.to_s}"
        puts '  to: ' + Rails.root.to_s + "/public/system/banners/#{b.id.to_s}"
        FileUtils.copy_entry(Rails.root.to_s + "/public/system/imgs/#{b.id.to_s}", Rails.root.to_s + "/public/system/banners/#{b.id.to_s}")
      else
        puts 'Banner already exists: ' + Rails.root.to_s + "/public/system/banners/#{b.id.to_s}"
      end
    }
  end

  def down
    remove_column :semi_static_entries, :unrestricted_html
  end
end
