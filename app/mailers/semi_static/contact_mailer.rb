module SemiStatic
  class ContactMailer < ActionMailer::Base
    def contact_notification(contact)
      subject = 'Website contact request'
      email = SemiStatic::Engine.config.contact_email

      @contact = contact
      @host = SemiStatic::Engine.config.mail_host
      @locale = :en
      mail(:from => SemiStatic::Engine.config.mailer_from, :to => email, :subject => subject)
    end
  end
end
