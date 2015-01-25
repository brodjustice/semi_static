module SemiStatic
  class Subscriber < ActiveRecord::Base
    attr_accessible :cancel_token, :email, :name, :surname, :telephone
    attr_accessor :state

    has_many :newsletter_deliveries

    before_create :generate_token

    validates_uniqueness_of :email

    
    def fullname
      name + ' ' + surname
    end

    def delivery_state(newsletter)
      (nd = self.newsletter_deliveries.find_by_newsletter_id(newsletter.id)).nil? ? 0 : nd.state
    end


    protected

    def generate_token
      self.cancel_token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless Subscriber.exists?(cancel_token: random_token)
      end
    end
  end
end
