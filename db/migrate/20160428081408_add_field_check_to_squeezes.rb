class AddFieldCheckToSqueezes < ActiveRecord::Migration
  def change
    add_column :semi_static_squeezes, :company_field, :boolean, :default => false
    add_column :semi_static_squeezes, :position_field, :boolean, :default => false
    add_column :semi_static_squeezes, :email_footer, :text
  end
end
