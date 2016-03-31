module SemiStatic
  class SubscriberMailer < ActionMailer::Base
    def subscriber_notification(subscriber)
      subject = 'Unsubscribe notification'
      email = SemiStatic::Engine.config.contact_email

      @subscriber = subscriber
      @host = SemiStatic::Engine.config.mail_host
      @locale = :en
      mail(:from => SemiStatic::Engine.config.mailer_from, :to => email, :subject => subject)
    end
  end
end
