module SemiStatic
  class NewsletterMailer < ActionMailer::Base
    helper SemiStatic::NewslettersHelper
    helper SemiStatic::SiteHelper

    def draft(admin, newsletter)
      prepare(newsletter)

      @subscriber = admin
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
      @from = @newsletter.sender_address || SemiStatic::Engine.config.info_email

      attachments.inline['logo.jpg'] = File.read("#{Rails.root}/app/assets/images/#{SemiStatic::Engine.config.logo_image.split('/').last}")
      @newsletter.draft_entry_objects.each{|e|
        if @newsletter.draft_entry_ids[e.id][:img_url].present?
          img_file_path = "#{Rails.root}/public/#{URI.decode(@newsletter.draft_entry_ids[e.id][:img_url]).split('?').first}"
          if File.file?(img_file_path)
            attachments.inline["#{e.id.to_s}.jpg"] = File.read(img_file_path)
          else
            # Cannot find the file to load inline
            attachments.inline["#{e.id.to_s}.jpg"] = File.read("#{Rails.root}/app/assets/images/missing.jpg")
          end
        end
        if e.doc.present?
          if File.file?(e.doc.path)
            attachments[e.doc_file_name] = File.read("#{Rails.root}/public/#{e.doc}")
          else
            # Cannot find the file
            attachments[e.doc_file_name] = File.read("#{Rails.root}/app/assets/images/missing.jpg")
          end
        end
      }
    end
  end
end
