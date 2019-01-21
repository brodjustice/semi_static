class CreateSemiStaticOrderItems < ActiveRecord::Migration[5.2]
  def change
    create_table :semi_static_order_items do |t|
      t.integer :product_id
      t.integer :order_id
      t.decimal :unit_price, precision: 12, scale: 3
      t.integer :quantity
      t.decimal :total_price, precision: 12, scale: 3

      t.timestamps
    end
  end
end
