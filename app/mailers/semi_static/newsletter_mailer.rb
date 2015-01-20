module SemiStatic
  class NewsletterMailer < ActionMailer::Base

    def draft(admin, newsletter)
      @subject = newsletter.name
      email = admin.email

      @admin = admin
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

      mail(:from => SemiStatic::Engine.config.mailer_from, :to => email, :subject => @subject)
    end
  end
end
