module SemiStatic
  class Subscriber < ActiveRecord::Base
    attr_accessible :cancel_token, :email, :name, :surname, :telephone, :locale
    attr_accessor :state

    has_many :newsletter_deliveries

    before_create :generate_token
    before_destroy :send_notice

    validates_uniqueness_of :email
    validates_format_of :email, :with => Devise.email_regexp
    validates_presence_of :email
    
    def fullname
      name.to_s + ' ' + surname.to_s
    end

    def delivery_state(newsletter)
      (nd = self.newsletter_deliveries.find_by_newsletter_id(newsletter.id)).nil? ? 0 : nd.state
    end

    def send_notice
      SemiStatic::SubscriberMailer.subscriber_notification(self).deliver
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
