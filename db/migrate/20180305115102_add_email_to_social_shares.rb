class AddEmailToSocialShares < ActiveRecord::Migration
  def change
    add_column :semi_static_entries, :email_share, :boolean, :default => false
  end
end
