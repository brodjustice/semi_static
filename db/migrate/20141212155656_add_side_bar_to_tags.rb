class AddSideBarToTags < ActiveRecord::Migration
  def change
    add_column :semi_static_tags, :side_bar, :boolean, :default => true
    add_column :semi_static_tags, :side_bar_news, :boolean, :default => true
    add_column :semi_static_tags, :side_bar_social, :boolean, :default => false
    add_column :semi_static_tags, :side_bar_search, :boolean, :default => false
  end
end