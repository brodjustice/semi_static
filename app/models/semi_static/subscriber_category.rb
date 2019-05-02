module SemiStatic
  class SubscriberCategory < ApplicationRecord
    has_many :subscribers
  end
end
