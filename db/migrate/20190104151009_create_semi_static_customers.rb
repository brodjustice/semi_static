class CreateSemiStaticCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :semi_static_orders, :customer_id, :integer
    create_table :semi_static_customers do |t|
      t.string		:title
      t.string		:name
      t.string		:surname
      t.string		:address_street
      t.string		:address_house_nr
      t.string		:address_line_2
      t.string		:address_city
      t.string		:address_country
      t.string		:company
      t.string		:position
      t.string		:email
      t.string		:phone
      t.string		:website
      t.timestamps
    end
  end
end
