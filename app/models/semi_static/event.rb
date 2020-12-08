module SemiStatic
  class Event < ApplicationRecord

    # For reference
    #
    # attr_accessible :name, :description, :location, :location_address, :tz, :door_time, :start_date, :end_date, :duration
    # attr_accessible :in_language, :typical_age_range
    # attr_accessible :offer_price, :offer_price_currency, :offer_max_price, :offer_min_price
    # attr_accessible :registration, :registration_url, :registration_text

    has_many :entries
    belongs_to :squeeze, :optional => true

    #
    # The symbols as significant as defined by schema.org https://schema.org/EventAttendanceModeEnumeration
    #
    ATTENDANCE_MODE = {
      :OfflineEventAttendanceMode => 1,
      :OnlineEventAttendanceMode => 2,
      :MixedEventAttendanceMode => 3,
    }

    ATTENDANCE_MODE_IDS = ATTENDANCE_MODE.invert

    #
    # The symbols as significant as defined by schema.org https://schema.org/EventStatusType
    #
    STATUS = {
      :EventCancelled => 1,
      :EventMovedOnline => 2,
      :EventPostponed => 3,
      :EventRescheduled => 4,
      :EventScheduled => 5
    }
 
    STATUS_IDS = STATUS.invert

  end
end
