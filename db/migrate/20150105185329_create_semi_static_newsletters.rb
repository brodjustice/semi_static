class CreateSemiStaticNewsletters < ActiveRecord::Migration
  def up
    create_table :semi_static_newsletters do |t|
      t.string :name
      t.integer :state
      t.string :locale, :default => 'en'
      t.text :draft_entry_ids
      t.text :html
      t.timestamps
    end

    create_table :semi_static_newsletter_deliveries do |t|
      t.integer :state
      t.integer :newsletter_id
      t.integer :contact_id
      t.timestamps
    end
  end

  def down
    drop_table :semi_static_newsletters
    drop_table :semi_static_newsletter_deliveries
  end
end
