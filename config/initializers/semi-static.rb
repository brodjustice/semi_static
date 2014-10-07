# Don't panic about the copyright, we are not claiming it. This is the copyright for the
# website contents, so remove or edit it as appropriate
SemiStatic::Engine.config.copyright_year = '2014'
SemiStatic::Engine.config.copyright_owner = 'Business Landing Ltd'

# The site name will be used in the webpage title, etc. but also for the selasticsearch indexing
SemiStatic::Engine.config.site_name = 'Business Landing Ltd'
SemiStatic::Engine.config.info_email = 'info@business-landing.com'
SemiStatic::Engine.config.telephone = nil

# Various social media links. Set to blank if don't have accounts on these media
SemiStatic::Engine.config.twitterID = 'businesslandingID'
SemiStatic::Engine.config.youtubeChannel = 'businesslandingID'
SemiStatic::Engine.config.facebookID = 'businesslandingID'

# This is the address to which the contact form data is sent to
SemiStatic::Engine.config.contact_email = 'brod@business-landing.com'

# These are the domains for your different language versions of your site
SemiStatic::Engine.config.localeDomains = { 'en' => 'http://127.0.0.1', 'de' => 'http://business-landing.de' }

# You may want to have a fallback locale, especially during development. Set it here
SemiStatic::Engine.config.default_locale = 'en'

# These are settings for the contact form and mailer
SemiStatic::Engine.config.mailer_from = 'contact_form@business-landing.com'
SemiStatic::Engine.config.mail_host = 'business-landing.com'

# Add name of partial here to be loaded to layouts for analytics, eg. Google 
# These will be combined for all locales so if you are using google make sure
# it is set up to accept your different locale websites.
#
# SemiStatic::Engine.config.analytics_partial = 'site/analytics'
SemiStatic::Engine.config.analytics_partial = nil

# Add name for partial which will provide address and contact details if required. If
# nil, then only the contact form will be shown
SemiStatic::Engine.config.contact_partial = nil
