class CreateSemiStaticOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :semi_static_products, :active, :boolean
    add_column :semi_static_products, :orderable, :boolean, :default => false
    create_table :semi_static_orders do |t|
      t.decimal :subtotal, precision: 12, scale: 3
      t.decimal :tax, precision: 12, scale: 3
      t.decimal :shipping, precision: 12, scale: 3
      t.decimal :total, precision: 12, scale: 3
      t.string :currency
      t.string :order_status

      t.timestamps
    end
  end
end
