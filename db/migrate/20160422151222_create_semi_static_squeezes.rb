class CreateSemiStaticSqueezes < ActiveRecord::Migration
  def change
    create_table :semi_static_squeezes do |t|
      t.string		:name
      t.string		:title
      t.text		:agreement
      t.text		:teaser
      t.text		:instructions
      t.string		:token
      t.string          :doc_file_name
      t.string          :doc_content_type
      t.integer         :doc_file_size
      t.timestamps
    end
    add_column :semi_static_contacts, :title, :string
    add_column :semi_static_contacts, :company, :string
    add_column :semi_static_contacts, :address, :string
    add_column :semi_static_contacts, :position, :string
    add_column :semi_static_contacts, :country, :string
    add_column :semi_static_contacts, :employee_count, :string
    add_column :semi_static_contacts, :branch, :string
    add_column :semi_static_contacts, :token, :string
    add_column :semi_static_contacts, :squeeze_id, :integer
    add_column :semi_static_contacts, :strategy, :integer, :default => 0
    add_column :semi_static_entries, :squeeze_id, :integer
  end
end
