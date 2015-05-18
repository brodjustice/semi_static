class AddSalutationToNewsletter < ActiveRecord::Migration
  def change
    add_column :semi_static_newsletters, :salutation, :boolean, :default => false
    add_column :semi_static_newsletters, :salutation_type, :integer
    add_column :semi_static_newsletters, :salutation_pre_text, :string, :default => ''
    add_column :semi_static_newsletters, :salutation_post_text, :text, :default => ''
  end
end
