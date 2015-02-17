class AddSitemapDataToSeos < ActiveRecord::Migration
  def change
    add_column :semi_static_seos, :include_in_sitemap, :boolean, :default => true
    add_column :semi_static_seos, :changefreq, :integer, :default => 0
    add_column :semi_static_seos, :priority, :integer, :default => 5
  end
end
