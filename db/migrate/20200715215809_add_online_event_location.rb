class AddOnlineEventLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :semi_static_events, :online_url, :string
  end
end
