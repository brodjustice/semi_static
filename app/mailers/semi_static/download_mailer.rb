module SemiStatic
  class DownloadMailer < ActionMailer::Base
    def download_instructions(contact)
      subject = t('DownloadInstructionsFrom')
      email = contact.email

      @host = SemiStatic::Engine.config.mail_host
      @contact = contact
      mail(:from => SemiStatic::Engine.config.mailer_from, :to => email, :subject => subject)
    end
  end
end
