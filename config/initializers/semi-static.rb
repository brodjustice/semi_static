module SemiStatic
  class Engine < Rails::Engine
    # We grab the exceptions and serve dynamic error pages. Remove this bit if you
    # want your own error pages, or even the standard ugly ones.
    unless Rails.env.development? || Rails.env.test?
      Rails.application.config.exceptions_app = SemiStatic::Engine.routes
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
    config.youtubeChannel = 'channel/UCgm36i95RcaPTJzqEKt4zhw'
    config.twitterID = nil
    config.facebookID = nil
    config.xingID = nil

    # Themes: Current options are:
    #
    #   1. standard-2col-1col
    #   2. plain-3col
    #   3. plain-big-banner-3col
    #   4. parallax
    #   5. menu-right
    config.theme = 'menu-right'
    
    # This is the address to which the contact form data is sent to
    config.contact_email = 'info@business-landing.com'
    
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
    
    # Add name for partial which will provide imprint/impressum, terms and conditions etc. If
    # nil, then the contact partial, if any, will be used
    config.imprint_partial = nil
    
    # Add name for partial which will provide embedded social widgets on your home page
    # if nil, then nothing will be shown
    config.social_partial = nil

    # Your own partials that can be used in Entries and Tags views should be stored in
    # ./app/views/semi_static/partials. SemiStatic will then automatically make them available
    # to the admin dashboard when you edit a new entry or tag. If you really want
    # to add manually, then add them here
    # config.open_partials = {:cool_partial => 'site/cool_partial'}
    config.open_partials = {}
  end
end
