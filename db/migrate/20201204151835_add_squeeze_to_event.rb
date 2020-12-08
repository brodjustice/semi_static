class AddSqueezeToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :semi_static_events, :squeeze_id, :integer
  end
end
