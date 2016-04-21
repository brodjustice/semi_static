class AddRegistrationToEvent < ActiveRecord::Migration
  def change
    add_column :semi_static_events, :registration, :boolean, :default => false
    add_column :semi_static_events, :registration_text, :string
    add_column :semi_static_events, :registration_url, :string
    add_column :semi_static_contacts, :reason, :string
  end
end
