module SemiStatic
  class Event < ActiveRecord::Base

    # For reference
    #
    # attr_accessible :name, :description, :location, :location_address, :tz, :door_time, :start_date, :end_date, :duration
    # attr_accessible :in_language, :typical_age_range
    # attr_accessible :offer_price, :offer_price_currency, :offer_max_price, :offer_min_price
    # attr_accessible :registration, :registration_url, :registration_text

    has_many :entries

  end
end
