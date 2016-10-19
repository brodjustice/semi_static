class AddUnsubscribeToSubscribers < ActiveRecord::Migration
  def change
    add_column :semi_static_subscribers, :unsubscribe, :boolean, :default => false
  end
end
