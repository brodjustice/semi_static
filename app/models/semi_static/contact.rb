module SemiStatic
  class Contact < ActiveRecord::Base
    attr_accessible :surname, :message, :email, :telephone, :name, :locale, :agreement_ids

    has_and_belongs_to_many :agreements, :join_table => :semi_static_agreements_contacts
  
    # TODO: The load order of the locales files stops us adding the correct message for this, its
    # needs to say 'Please provide either an email or telephone number'
    # validates_presence_of :telephone, :unless => :email?
    validates_format_of :email, :with => /.+@.+\..+/i, :allow_blank => true, :allow_nil => true
    validates_presence_of :email, :unless => :telephone?
  
    after_create :send_email
    after_create :check_subscription
  
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
  
    def send_email
      SemiStatic::ContactMailer.contact_notification(self).deliver
    end
  end
end
