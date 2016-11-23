module SemiStatic
  class Contact < ActiveRecord::Base
    attr_accessible :reason, :surname, :message, :email, :telephone, :name, :locale, :agreement_ids, :strategy, :squeeze_id
    attr_accessible :title, :company, :address, :position, :country, :employee_count, :branch
    attr_accessor :custom_params

    has_and_belongs_to_many :agreements, :join_table => :semi_static_agreements_contacts
    belongs_to :squeeze
  
    # TODO: The load order of the locales files stops us adding the correct message for this, its
    # needs to say 'Please provide either an email or telephone number'
    # validates_presence_of :telephone, :unless => :email?
    validates_format_of :email, :with => /.+@.+\..+/i, :allow_blank => true, :allow_nil => true
    validates_presence_of :email, :unless => :telephone?
  
    after_create :execute_strategy
    after_create :check_subscription

    STRATEGIES = { :message => 0, :registration => 1, :download => 2, :subscriber => 3 }
    STRATEGY_CODES = STRATEGIES.invert
  
    def check_subscription
      unless self.email.blank? || self.agreements.subscriber.blank?
        if (s = SemiStatic::Subscriber.find_by_email(self.email)).blank?
          s = SemiStatic::Subscriber.create(:surname => surname, :name => name, :email => email, :telephone => telephone, :locale => locale)
        else
          attributes.each{|k,v| attributes.delete(k) if read_attribute(k).blank?}
          s.update_attributes(:name => s.name, :surname => s.surname, :telephone  => s.telephone, :locale => s.locale)
        end
        s.category = SemiStatic::SubscriberCategory.find_by_name('website')
        s.save
      end
    end

    def fullname
      [name, surname].join(' ')
    end
  
    def execute_strategy
      self.send('strat_' + (STRATEGY_CODES[strategy] || :message).to_s)
    end

    def strategy_sym
      STRATEGY_CODES[strategy].to_sym
    end

    # Stratgies - always prefixed with 'strat_'

    def strat_message
      SemiStatic::ContactMailer.contact_notification(self).deliver
    end

    def strat_registration
      SemiStatic::ContactMailer.contact_notification(self).deliver
    end

    def strat_subscriber
      SemiStatic::ContactMailer.contact_notification(self).deliver
    end

    def strat_download
      self.token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless Contact.exists?(token: random_token)
      end
      self.reason ||= (self.squeeze && self.squeeze.title)
      self.save
      SemiStatic::DownloadMailer.download_instructions(self).deliver
    end
  end
end
