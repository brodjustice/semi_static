module SemiStatic
  class NewsletterMailer < ActionMailer::Base
    helper SemiStatic::NewslettersHelper

    def draft(admin, newsletter)
      prepare(newsletter)

      @email = admin.email

      mail(:from => @from, :to => admin.email, :subject => @subject, :template_name => 'newsletter')
    end

    def publish(delivery)
      prepare(delivery.newsletter)

      @subscriber = delivery.subscriber
      @email = @subscriber.email

      email_with_name = %("#{@subscriber.fullname}" <#{@subscriber.email}>)

      mail(:from => @from, :to => email_with_name, :subject => @subject, :template_name => 'newsletter')
    end

    private

    def prepare(newsletter)
      @subject = newsletter.name

      @newsletter = newsletter
      @host = SemiStatic::Engine.config.mail_host
      @locale = newsletter.locale
      @site_url = SemiStatic::Engine.config.hosts_for_locales.invert[@locale]
      @from = @newsletter.sender_address || SemiStatic::Engine.config.mailer_from

      attachments.inline['logo.jpg'] = File.read("#{Rails.root}/app/assets/images/#{SemiStatic::Engine.config.logo_image.split('/').last}")
      @newsletter.draft_entry_objects.each{|e|
        if e.img.present? && File.file?(e.img.path)
          attachments.inline["#{e.id.to_s}.jpg"] = File.read("#{Rails.root}/public/#{e.img_url_for_theme(:desktop)}")
        end
        if e.doc.present? && File.file?(e.doc.path)
          attachments[e.doc_file_name] = File.read("#{Rails.root}/public/#{e.doc}")
        end
      }
    end
  end
end
