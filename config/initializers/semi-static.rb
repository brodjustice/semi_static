# encoding: utf-8

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
    # config.logo_image = 'logo.png'
    config.logo_image = nil

    # Favicon image
    config.favicon_image = 'favicon.ico'

    # Your additional custom META tags, eg
    # config.custom_meta_tags = {
    #   'de' => {'facebook-domain-verification' => 'afli2wsdasf4crzi99ebxjsoj33j4g'},
    #   'en' => {'facebook-domain-verification' => 'mal04nasasadsadsa56be7uwsotlis'}
    # }

    # If you want just text instead of a logo, put it here
    config.logo_text = nil

    config.info_email = 'info@business-landing.com'
    config.telephone = nil

    # Various social media links. Set to blank if don't have accounts on these media
    # config.youtubeChannel = 'channel/UCgm36i95RcaPTJzqEKt4zhw'
    config.youtubeChannel = nil
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

    # This is the address to which the contact form data is sent to. Seperate with commas
    # if you have more that one delivery adddress
    config.contact_email = 'info@business-landing.com'

    # If you want a custom email subject for contact form emails, add it here
    #   config.contact_email_subject = 'Solicitud contacto página web'

    # This is the address to which the blog comment email alert is sent to - if a blog is used.
    # If set to nil, the config.contact_email addresses are used instead
    config.comment_email = nil

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

    # Display of locale link in top bar between websites, default is :flags.
    # Also :text (eg. 'English') and :locales (eg. 'EN')
    config.locale_display = :flags

    # You may want to have a fallback locale, especially during development. Set it here
    config.default_locale = 'en'

    # These are settings for the contact form and mailer. Make sure that the config.mailer_from
    # has a full and correct domain, else some email systems will just silently ignore the email.
    config.mailer_from = 'contact_form@business-landing.com'
    config.mail_host = 'business-landing.com'

    # This is the email address for mails sent out due to a squeeze. If nil the contact email
    # will be used.
    config.squeeze_email = nil

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

    # Set to true if using Google Analytics 4 (GA4)
    config.ga4 = true

    # Add name for partial which will provide address and contact details if required. If
    # nil, then only the contact form will be shown
    config.contact_partial = nil

    # If set to true this will put a fake URL message form field into the semi_static contact form
    # but hide it with CSS. Spambots will be tempted to fill out the fields, while normal users will
    # not see the fields at all. In this way we can stop a lot of contact form spam.
    config.contact_form_spam_fields = true

    # If you provide a comma seperated list of character strings, then these will be checked against
    # the email address on your contact for spam sources. For example, if you want to stop emails
    # from all yahoo email addresses and from 'spammer@gmail.com' you would use:
    #   config.contact_form_spam_email = 'yahoo, spammer@gmail.com'
    #
    config.contact_form_spam_email = false

    # Will do stricter checking of the contact form inputs, eg. checking if they are real names rather
    # than urls.
    #
    config.contact_form_strict = true

    # Add name for partial which will provide imprint/impressum, terms and conditions etc. If
    # nil, then the contact partial, if any, will be used
    config.imprint_partial = nil

    # Add name for partial which will provide embedded social widgets on your home page
    # if nil, then nothing will be shown
    config.social_partial = nil

    # If nil any sitemap that you generate from the admin dashboard will just be send as a
    # download. If set, then the sitemap will be added to the public directory under the
    # filename given here. This will also cause a ping to be sent to Google in order to
    # cause a check for a new sitemap.
    config.sitemap = 'sitemap.xml'

    # Set the shopping cart to true so that the visitor can add products to their cart
    # and use a checkout.
    config.shopping_cart = false

    # Set the default currency for your products. If you have enable the shopping cart
    # then you must provide a default currency. Currencies are in the ISO4217 format,
    # eg EUR, USD, GBP, etc.
    config.default_currency = 'EUR'

    # The only payment strategies are currently :email and :stripe. The :email strategy is the
    # default and simply sends an email of the shopping cart to the website info address so that
    # a manual invoice can be sent out. The :stripe strategy uses stripe.com online payment system,
    # so you need to have a stripe account and to have set up your environment to pass your
    # stripe API keys as described on the strip developers section on their website.
    #
    # config.payment_strategy = :email
    # config.payment_strategy = :stripe
    config.payment_strategy = :email

    # Your own custom partials that can be used in Entries and Tags views should be stored in
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
    # Note that you will also need to add the following helper to your controller:
    #     helper SemiStatic::DashboardHelper
    config.dashboard_menu_additions = nil

    # To increase your SEO you can replace certain words in your URLs
    # IMPORTANT: Do not use symbols for your locale, eg. use 'en' not :en
    # config.tag_paths = { 'en' => 'features', 'de' => 'merkmale' }
    # config.tag_paths = { 'en' => 'features', 'de' => 'merkmale', 'es' => 'caracteristicas', 'it' => 'caratteristiche', 'fr' => 'caracteristiques' }


    # If a newsletter logo is given, this will be used instead of the normal website or meta tags logo,
    # this helps if you wnat to have a very compressed lightweight logo for you newsletters or just
    # perhaps a different background
    # config.newsletter_logo = 'newsletter-logo.jpg'
  end
end
