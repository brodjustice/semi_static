module SemiStatic
  class Subscriber < ActiveRecord::Base
    attr_accessible :cancel_token, :email, :name, :surname, :telephone, :locale, :company, :position, :country, :subscriber_category_id
    attr_accessor :state

    belongs_to :category, :class_name => SubscriberCategory, :foreign_key => :subscriber_category_id
    has_many :newsletter_deliveries, :dependent => :destroy

    before_create :generate_token
    before_destroy :send_notice

    validates_uniqueness_of :email
    validates_format_of :email, :with => Devise.email_regexp
    validates_presence_of :email

    delegate :name, :to => :category, :allow_nil => true, :prefix => true
    
    def fullname
      (name == surname) ? name : [name, surname].join(' ')
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
