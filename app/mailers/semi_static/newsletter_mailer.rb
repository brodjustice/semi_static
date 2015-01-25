module SemiStatic
  class NewsletterMailer < ActionMailer::Base

    def draft(admin, newsletter)
      prepare(newsletter)

      mail(:from => SemiStatic::Engine.config.mailer_from, :to => admin.email, :subject => @subject)
    end

    def publish(delivery)
      prepare(delivery.newsletter)

      mail(:from => SemiStatic::Engine.config.mailer_from, :to => delivery.subscriber.email, :subject => @subject)
    end

    private

    def prepare(newsletter)
      @subject = newsletter.name

      @newsletter = newsletter
      @host = SemiStatic::Engine.config.mail_host
      @locale = newsletter.locale

      attachments.inline['logo.jpg'] = File.read("#{Rails.root}/app/assets/images/#{SemiStatic::Engine.config.logo_image.split('/').last}")
      @newsletter.draft_entry_objects.each{|e|
        if e.img.present?
          attachments.inline["#{e.id.to_s}.jpg"] = File.read("#{Rails.root}/public/#{e.img_url_for_theme(:desktop)}")
        end
        if e.doc.present?
          attachments[e.doc_file_name] = File.read("#{Rails.root}/public/#{e.doc}")
        end
      }
    end
  end
end
