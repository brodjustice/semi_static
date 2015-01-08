module SemiStatic
  class NewsletterDelivery < ActiveRecord::Base
    belongs_to :newsletter
    belongs_to :contact
  end
end
