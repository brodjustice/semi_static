class AddCompanyAndPositionToSubscribers < ActiveRecord::Migration
  def change
    add_column :semi_static_subscribers, :company, :string
    add_column :semi_static_subscribers, :position, :string
    add_column :semi_static_subscribers, :country, :string
  end
end
