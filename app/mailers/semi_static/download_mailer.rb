module SemiStatic
  class DownloadMailer < ActionMailer::Base
    def download_instructions(contact)
      subject = contact.squeeze.email_subject
      email = contact.email

      @host = SemiStatic::Engine.config.mail_host
      @contact = contact
      @url = document_url(@contact.squeeze.id, @contact.token, :host => URI.parse(SemiStatic::Engine.config.localeDomains[@contact.locale]).host)
      mail(:from => SemiStatic::Engine.config.info_email, :to => email, :subject => subject)
    end
  end
end
