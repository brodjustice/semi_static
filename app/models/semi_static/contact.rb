module SemiStatic
  class Contact < ActiveRecord::Base
    attr_accessible :surname, :message, :email, :telephone, :name
  
    validates_presence_of :telephone, :unless => :email?
    validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true, :allow_nil => true
  
    after_create :send_email
  
    def fullname
      name + ' ' + surname
    end
  
    def send_email
      ContactMailer.contact_notification(self).deliver
    end
  end
end
