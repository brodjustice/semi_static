module SemiStatic
  class SubscriberCategory < ActiveRecord::Base
    has_many :subscribers
  end
end
