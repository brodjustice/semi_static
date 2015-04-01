module SemiStatic
  class NewsletterDelivery < ActiveRecord::Base
    attr_accessible :state
    belongs_to :newsletter
    belongs_to :subscriber

    STATES = {
      :not_set => 0,
      :pending => 0x1,
      :sent => 0x2,
      :error => 0x3,
      :bounced => 0x4
    }

    STATE_CODES = STATES.invert

    scope :pending, where(:state => NewsletterDelivery::STATES[:pending])
    scope :delivered, where(:state => NewsletterDelivery::STATES[:sent])

    delegate :fullname, :to => :subscriber, :allow_nil => true
    delegate :email, :to => :subscriber, :allow_nil => true

    def sent
      self.state = STATES[:sent]
      self.save
    end

  end
end
