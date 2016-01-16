module SemiStatic
  class Engine < Rails::Engine
    # We grab the exceptions and serve dynamic error pages. Remove this bit if you
    # want your own error pages, or even the standard ugly ones.
    unless Rails.env.development? || Rails.env.test?
      Rails.application.config.exceptions_app = SemiStatic::Engine.routes
    end

    # Don't panic about the copyright, we are not claiming it. This is the copyright for the
    # website contents, so remove or edit it as appropriate. Leave the copyright year as
    # nil and semi_static will use the current year (restart to update) else supply your
    # own year:
    # config.copyright_year = '2027'
    config.copyright_year = nil
    config.copyright_owner = 'Business Landing Ltd'
    
    # The site name will be used in the webpage title, open graph meta tags, etc. but also for the elasticsearch indexing
    config.site_name = 'Business Landing Ltd'

    # Correct logo path is important for the Open Graph meta tags
    # config.logo_image = '/assets/logo.png'
    config.logo_image = nil

    config.info_email = 'info@business-landing.com'
    config.telephone = nil
    
    # Various social media links. Set to blank if don't have accounts on these media
    config.youtubeChannel = 'channel/UCgm36i95RcaPTJzqEKt4zhw'
    config.twitterID = nil
    config.facebookID = nil
    config.xingID = nil
    config.linkedinID = nil
    config.googleplusID = nil
    config.instagramID = nil
    config.kununuID = nil


    # Themes: Current options are:
    #
    #   1. standard-2col-1col
    #   2. plain-3col
    #   3. plain-big-banner-3col
    #   4. parallax
    #   5. menu-right
    #   6. tiles
    #   7. bannerette-2col-1col
    #   8. bannerless
    #   9. background-cover
    config.theme = 'bannerless'

    # Specific search box will be shown on home page unless this is set:
    config.disable_search_in_home_page = false

    # Some themes, like bannerette have an option for a top level menu mouse
    # over/hover sub menu. Set this if you want this enabled
    # config.hover_menu = true

    # The path for your elasticsearch binary
    config.elasticsearch = '/home/bl/elasticsearch/elasticsearch-1.7.2/bin/elasticsearch'
    
    # This is the address to which the contact form data is sent to
    config.contact_email = 'info@business-landing.com'
    
    # These are the domains for your different language versions of your site. This will
    # also be used used to generate the hreflang tags to point to the alternate language
    # versions of the website home page. If you have multiple deomains for one language, eg. .com and
    # a .biz, then this should be handled by a webserver redirect and only the main
    # langauge domain should fo here (this is better for search indexing)
    #
    # You can also add a flag for google translate instead like this:
    # { 'en' => 'http://my-website.com', 'es' => 'translate' }
    #
    config.localeDomains = { 'en' => 'http://127.0.0.1', 'de' => 'http://business-landing.de' }
    
    # You may want to have a fallback locale, especially during development. Set it here
    config.default_locale = 'en'
    
    # These are settings for the contact form and mailer
    config.mailer_from = 'contact_form@business-landing.com'
    config.mail_host = 'business-landing.com'
    
    # Set to false if you don't want to show client logos in a side bar or the main reference page
    config.reference_logos = true

    # Predefined Models/Paths: Besides the SemiStatic predefined Models you can add your
    # own here. These are then available to the (menu) Tags for direct link to your
    # applications own views.
    # config.predefined = {'FAQ' => 'faqs_path', 'cakes' => ['cakes', 'all'] }    
    config.predefined = {}    

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

    # If your application has it's own dashboard, especially an admin dashboard, you may
    # want the semi_static admin to return to this dashboard when finished with the 
    # semi-static dashboard. If so put your dashboard path in here
    # config.app_dashboard = ['dashboard_path', 'admin']
    config.app_dashboard = false

    # If you have your own 'users' devise model created with 'rails g devise user' 
    # in order to have a user sign-in area, then add the model name here , eg:
    # config.subscribers_model = {'User' => 'new_user_session_path'}
    config.subscribers_model = nil

    #
    # In this case semi_static will assume that there is a dashboard path that
    # can be inferred from the model name, eg:
    #   user_dashboard_path
    #
    # If you do this, then you might need access to the 'users' via the dashbord,
    # so then you will also need to add appropriate hash to the config.dashboard_menu_additions
    # below, something like:
    # config.dashboard_menu_additions = {'users' => 'users_path'}

    # Or if you just want to add a menu item to the dashboards controller then add it here
    # config.app_dashboard_menu_additions = false
    # config.dashboard_menu_additions = {'analyses' => 'analyses_path'}
    config.dashboard_menu_additions = nil

    # To increase your SEO you can replace certain words in your URLs
    # IMPORTANT: Do not use symbols for your locale, eg. use 'en' not :en
    # config.tag_paths = { 'en' => 'features', 'de' => 'merkmale' }
    config.tag_paths = { 'en' => 'features', 'de' => 'merkmale', 'es' => 'caracteristicas', 'it' => 'caratteristiche', 'fr' => 'caracteristiques' }

    # If a newsletter logo is given, this will be used instead of the normal website or meta tags logo,
    # this helps if you wnat to have a very compressed lightweight logo for you newsletters or just
    # perhaps a different background
    # config.newsletter_logo = '/assets/logo.jpg'
  end
end
