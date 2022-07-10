module SemiStatic
  class ContactMailer < ActionMailer::Base
    def contact_notification(contact)
      subject = if SemiStatic::Engine.config.respond_to?('contact_email_subject')
        SemiStatic::Engine.config.contact_email_subject.html_safe.force_encoding("utf-8")
      else
        'Website contact request'
      end
      email = SemiStatic::Engine.config.contact_email

      @contact = contact
      @host = SemiStatic::Engine.config.mail_host
      @locale = :en
      @reason = contact.reason
      @custom_params = contact.custom_params
      mail(:from => SemiStatic::Engine.config.mailer_from, :to => email, :subject => subject)
    end
  end
end
