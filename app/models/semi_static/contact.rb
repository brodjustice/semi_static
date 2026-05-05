module SemiStatic
  class Contact < ApplicationRecord

    attr_accessor :custom_params

    has_and_belongs_to_many :agreements, :join_table => :semi_static_agreements_contacts
    belongs_to :squeeze, :optional => true

    # TODO: The load order of the locales files stops us adding the correct message for this, its
    # needs to say 'Please provide either an email or telephone number'
    # validates_presence_of :telephone, :unless => :email?
    validates_format_of :email, :with => /.+@.+\..+/i, :allow_blank => true, :allow_nil => true
    validates_presence_of :email, :unless => :telephone?
    validates_presence_of :message, :unless => -> { [STRATEGIES[:subscriber], STRATEGIES[:download]].include?(strategy) }
    validate :spam_email?

    after_create :execute_strategy
    after_create :check_subscription

    default_scope { order(created_at: :desc) }

    STRATEGIES = { :message => 0, :registration => 1, :download => 2, :subscriber => 3, :application => 4}
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

    def spam_email?
      if SemiStatic::Engine.config.contact_form_spam_email
        strs = SemiStatic::Engine.config.contact_form_spam_email.split(',')
        normalized = gmail_dot_normalize(self.email)
        if strs.any?{|word| normalized.include?(word.strip)}
          self.errors.add(
            :base, 'This appears to be SPAM. Sorry, we cannot process this request, please send email to '+
              SemiStatic::Engine.config.info_email
          )
        end
      end
      if dotted_gmail_spam?(self.email)
        self.errors.add(
          :base, 'This appears to be SPAM. Sorry, we cannot process this request, please send email to '+
            SemiStatic::Engine.config.info_email
        )
      end
      if SemiStatic::Engine.config.contact_form_strict
        # Check for URL in name field
        if self.name&.match(/^http/) || self.surname&.match(/^http/)
          self.errors.add(
            :base, 'This appears to be a SPAM link. Sorry, we cannot process this request, please send email to '+
              SemiStatic::Engine.config.info_email
          )
        end
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

    private

    # Gmail ignores dots in the local part, so a.b.c@gmail.com == abc@gmail.com.
    # Normalise before spam-list matching so dotted variants are caught too.
    def gmail_dot_normalize(email)
      return email.to_s if email.blank?
      local, domain = email.to_s.split('@', 2)
      return email unless domain&.downcase == 'gmail.com'
      "#{local.gsub('.', '')}@#{domain}"
    end

    # Heuristic: Gmail addresses with 4+ dot-separated segments are a common
    # auto-generated spam pattern, e.g. eqi.kak.icu.pa.3.53@gmail.com
    def dotted_gmail_spam?(email)
      return false if email.blank?
      email.match?(/\A[a-z0-9]+(\.[a-z0-9]+){3,}@gmail\.com\z/i)
    end
  end
end
