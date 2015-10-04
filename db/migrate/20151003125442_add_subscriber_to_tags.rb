class AddSubscriberToTags < ActiveRecord::Migration
  def change
    add_column :semi_static_tags, :subscriber, :boolean, :default => false
  end
end
