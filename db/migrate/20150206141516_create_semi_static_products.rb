class CreateSemiStaticProducts < ActiveRecord::Migration
  def change
    create_table :semi_static_products do |t|
      t.string		:name
      t.text            :description
      t.string          :color
      t.string          :height
      t.string          :depth
      t.string          :width
      t.string          :weight
      t.string          :price
      t.string          :currency
      t.integer         :inventory_level, :default => 1
      t.integer         :entry_id
      t.timestamps
    end
  end
end
