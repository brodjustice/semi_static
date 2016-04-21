module SemiStatic
  class Event < ActiveRecord::Base
    attr_accessible :name, :description, :location, :tz, :door_time, :start_date, :end_date, :duration, :in_language, :typical_age_range

    has_many :entries

  end
end
