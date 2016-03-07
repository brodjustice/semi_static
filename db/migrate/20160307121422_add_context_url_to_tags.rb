class AddContextUrlToTags < ActiveRecord::Migration
  def change
    add_column :semi_static_tags, :context_url, :boolean, :default => false
  end
end
