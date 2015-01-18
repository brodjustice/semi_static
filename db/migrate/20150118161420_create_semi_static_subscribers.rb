class CreateSemiStaticSubscribers < ActiveRecord::Migration
  def change
    create_table :semi_static_subscribers do |t|
      t.string :name
      t.string :surname
      t.string :email
      t.string :telephone
      t.string :cancel_token

      t.timestamps
    end
    add_column :semi_static_newsletters, :subtitle, :string
    add_column :semi_static_agreements, :add_to_subscribers, :boolean, :default => false
    rename_column :semi_static_newsletter_deliveries, :contact_id, :subscriber_id
  end
end
