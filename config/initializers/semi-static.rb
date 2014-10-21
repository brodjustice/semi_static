module SemiStatic
  class Engine < Rails::Engine
    
    def partial_finder
      partials = {}
      if File.directory?(Rails.root.to_s + '/app/views/semi_static/partials')
        Dir.foreach(Rails.root.to_s + '/app/views/semi_static/partials'){|file|
          if file.start_with?('_') && file.include?('.html')
            file = file[1..-1].split('.')[0]
            partials[file.humanize] = "semi_static/partials/#{file}"
          end
        }
      end
      partials
    end

    # Don't panic about the copyright, we are not claiming it. This is the copyright for the
    # website contents, so remove or edit it as appropriate
    config.copyright_year = '2014'
    config.copyright_owner = 'Business Landing Ltd'
    
    # The site name will be used in the webpage title, etc. but also for the selasticsearch indexing
    config.site_name = 'Business Landing Ltd'
    config.info_email = 'info@business-landing.com'
    config.telephone = nil
    
    # Various social media links. Set to blank if don't have accounts on these media
    config.twitterID = 'businesslandingID'
    config.youtubeChannel = 'businesslandingID'
    config.facebookID = 'businesslandingID'
    config.xingID = 'businesslandingID'
    
    # This is the address to which the contact form data is sent to
    config.contact_email = 'brod@business-landing.com'
    
    # These are the domains for your different language versions of your site
    config.localeDomains = { 'en' => 'http://127.0.0.1', 'de' => 'http://business-landing.de' }
    
    # You may want to have a fallback locale, especially during development. Set it here
    config.default_locale = 'en'
    
    # These are settings for the contact form and mailer
    config.mailer_from = 'contact_form@business-landing.com'
    config.mail_host = 'business-landing.com'
    
    # Set to false if you don't want to show client logos in a side bar or the main reference page
    config.reference_logos = true

    # Add name of partial here to be loaded to layouts for analytics, eg. Google 
    # These will be combined for all locales so if you are using google make sure
    # it is set up to accept your different locale websites.
    #
    # config.analytics_partial = 'site/analytics'
    config.analytics_partial = nil
    
    # Add name for partial which will provide address and contact details if required. If
    # nil, then only the contact form will be shown
    config.contact_partial = nil
    
    # Add name for partial which will provide embedded social widgets on your home page
    # if nil, then nothing will be shown
    config.social_partial = nil

    # Your own partials that can be used in Entries and Tags views should be stored in
    # ./app/views/semi_static/partials. SemiStatic will then automatically make them available
    # to the admin dashboard when you edit a new entry or tag.
    config.open_partials = partial_finder
  end
end
