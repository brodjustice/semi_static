class AddLocationAddressToEvents < ActiveRecord::Migration
  def change
    add_column :semi_static_events, :location_address, :string
    add_column :semi_static_events, :offer_price_currency, :string
    add_column :semi_static_events, :offer_price, :float
  end
end
