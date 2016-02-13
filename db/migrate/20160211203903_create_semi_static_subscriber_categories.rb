class CreateSemiStaticSubscriberCategories < ActiveRecord::Migration
  def self.up
    create_table :semi_static_subscriber_categories do |t|
      t.string		:name
      t.timestamps
    end
    add_column :semi_static_subscribers, :subscriber_category_id, :integer
    SemiStatic::SubscriberCategory.reset_column_information
    SemiStatic::Subscriber.reset_column_information
    SemiStatic::SubscriberCategory.create(:name => 'website')
    sc = SemiStatic::SubscriberCategory.create(:name => 'default')
    SemiStatic::Subscriber.all.each do |s|
      s.category = sc
      s.save
    end
  end

  def self.down
    drop_table :semi_static_subscriber_categories
    remove_column :semi_static_subscribers, :subscriber_category_id
  end
end
