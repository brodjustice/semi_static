class AddNewsletterToTags < ActiveRecord::Migration
  def change
    add_column :semi_static_tags, :newsletter_id, :integer, :default => nil
  end
end
