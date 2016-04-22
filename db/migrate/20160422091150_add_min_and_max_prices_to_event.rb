class AddMinAndMaxPricesToEvent < ActiveRecord::Migration
  def change
    add_column :semi_static_events, :offer_min_price, :float
    add_column :semi_static_events, :offer_max_price, :float
  end
end
