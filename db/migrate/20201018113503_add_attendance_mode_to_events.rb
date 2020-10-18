class AddAttendanceModeToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :semi_static_events, :attendance_mode, :integer, :default => SemiStatic::Event::ATTENDANCE_MODE[:OfflineEventAttendanceMode]
    add_column :semi_static_events, :status, :integer, :default => SemiStatic::Event::STATUS[:EventScheduled]
  end
end
