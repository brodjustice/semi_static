class AddCssToNewletters < ActiveRecord::Migration
  def change
    add_column :semi_static_newsletters, :css, :text
    add_column :semi_static_newsletters, :sender_address, :string
  end
end
