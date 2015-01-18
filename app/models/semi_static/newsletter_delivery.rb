module SemiStatic
  class NewsletterDelivery < ActiveRecord::Base
    belongs_to :newsletter
    belongs_to :subscriber
  end
end
