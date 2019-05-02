module SemiStatic
  class NewsletterDelivery < ApplicationRecord

    belongs_to :newsletter
    belongs_to :subscriber

    #
    # We could have only one delivery per subsciber per newletter using this:
    #   validates_uniqueness_of :subscriber_id, :scope => :newsletter_id
    # But this would no longer leave an audit trail if we resend the newsletter
    #

    STATES = {
      :not_set => 0,
      :pending => 0x1,
      :sent => 0x2,
      :error => 0x3,
      :bounced => 0x4
    }

    STATE_CODES = STATES.invert

    default_scope { order(:updated_at => :desc)}

    scope :pending, -> {where(:state => NewsletterDelivery::STATES[:pending])}
    scope :delivered, -> {where(:state => NewsletterDelivery::STATES[:sent])}

    delegate :fullname, :to => :subscriber, :allow_nil => true
    delegate :email, :to => :subscriber, :allow_nil => true

    def sent
      self.state = STATES[:sent]
      self.save
    end

  end
end
