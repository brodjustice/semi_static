module SemiStatic
  class Subscriber < ActiveRecord::Base
    attr_accessible :cancel_token, :email, :name, :surname, :telephone
    attr_accessor :state

    before_create :generate_token

    validates_uniqueness_of :email

    
    def fullname
      name + ' ' + surname
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
