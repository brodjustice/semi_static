class CreateSemiStaticEvents < ActiveRecord::Migration
  def change
    create_table :semi_static_events do |t|
      t.string		:name
      t.text		:description
      t.string  	:time_zone
      t.datetime	:door_time
      t.datetime	:start_date
      t.datetime	:end_date
      t.integer		:duration
      t.string		:in_language
      t.string		:typical_age_range
      t.string		:location
      t.timestamps
    end
    add_column :semi_static_entries, :event_id, :integer
  end
end
