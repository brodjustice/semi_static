module SemiStatic
  class Contact < ActiveRecord::Base
    attr_accessible :surname, :message, :email, :telephone, :name, :agreement_ids

    has_and_belongs_to_many :agreements, :join_table => :semi_static_agreements_contacts
  
    # TODO: The load order of the locales files stops us adding the correct message for this, its
    # needs to say 'Please provide either an email or telephone number'
    # validates_presence_of :telephone, :unless => :email?
    validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true, :allow_nil => true
  
    after_create :send_email
  
    def fullname
      name + ' ' + surname
    end
  
    def send_email
      SemiStatic::ContactMailer.contact_notification(self).deliver
    end
  end
end
