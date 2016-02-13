module SemiStatic
  class SubscriberCategory < ActiveRecord::Base
    attr_accessible :name
    
    has_many :subscribers
  end
end
