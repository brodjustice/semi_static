= SemiStatic

A Rails 3 Engine to get you quickly started with a fast, cached, static website. Can however dynamically add content
hence the name 'semi-static'. The HTML site should load very quickly on mobile and desktop devices, and should get
a 100% rating on Google pagespeed.

Some tricks that are used to get the fast performance:

1. No javascript on most pages, animations via HTML5
2. Most images in sprite form
3. Home page fonts loaded in-line
4. Home page css loaded in-line
5. HDPI image support via massive compression
6. Full page cacheing whenever possible, with full multi-locale support
7. Option to pre-build gzipped static pages

= To install

Assuming you want to start with a clean applicaion, then first create your rails application:

Create your new rails application, for example using the postgres DB:

	# rails new myapp -d postgresql

With rails 3 your app will probably need a js runtime for the development environment, so uncomment that line in 'Gemfile':

	gem 'therubyracer', :platforms => :ruby

Create the database

	# rake db:setup

Now add semi-static

Edit the Gemfile to include the semi-static gem/engine:

	gem 'semi_static', :git => 'git://github.com/brodjustice/semi_static.git'

Run the bundler

	# bundle install

Run the semi-static install generator. SemiStatic needs some authentication and has so far only been tested with Devise. If this generator finds Devise or even a database table called 'users', then it will not try to set up autherntication. If it does not find authentication it will ask you if you want to set it up, and then take you through the process of setting up Devise with a single administrator account.

	# rails g semi_static_install

Start your app

	# rails s

= Browser support

All modern browsers and IE >= 9 should be supported.

= Configuration

The minimal configuration will require you to edit the 'config/initializers/semi_static.rb' file. Edit that file to
suit your configuration. Thereafter you can customize the css files and overwrite the views to customize as much as
you want.

= Content

The initial admin sign in email and password can by found in db/seeds.rb. Use this to sign in and start adding your content.
Note: seeds.rb is created by the generator, so you must have run this first as decribed above.

= Production environment webserver, assets and page cacheing

Semi-static saves cached versions of your sites pages in the public directory, but inside directories according to the locale
of the content. Exactly which locales match which domains is set in 'config/initializers/semi-static.rb'. So for example your
will find the english version of your home page at:

    public/en/home.html

Your webserver needs to be configured to take advantage of this. For ngnix the configuration will look something like this:

    server {
      # myapp.com
      listen 80;
      server_name myapp.com *.myapp.com;

      # Add locale directory to the root directory
      root /home/bl/myapp/public/en;
      passenger_app_root /home/bl/myapp;

      location ~ ^/(assets)/  {
        expires 90d;
        add_header Cache-Control public;
        break;
      }

      # Paperclip will upload assets to /public/system... without a cache busting string
      # so we simply set a reasonable expiry date on them
      location ~ ^/(system)/  {
        expires 1w;
        add_header Cache-Control public;
        break;
      }

      # Expires header required for some browsers e.g. Firefox. Setting expires to 0 will
      # possibly lower your Google Pagespeed, so set to 1 second.
      expires    modified 1s;
      add_header Cache-Control public;

      client_max_body_size 20m;

      rails_env production;
      passenger_enabled on;
    }

To make sure that the webserver finds your assets, and assuming that you want to share your assets between your various locales, you will
need to link the 'asset' and 'system' directories inside each of the public locale directories to the top level 'public' directories:

    # cd public/en
    # ln -s ../assets ./assets
    # ln -s ../system ./system

= Using the window.onload event in javascript

Some SemiStatic pages need to use the window.onload event. If you try and use the window.onload event yourself in a page you may have unpredictable
results. Therefore SemiStaic provides the addSemiStaticLoadEvent() function. Use this function to call any javascript that you need to execute
when the document is loaded, eg:

    addSemiStaticLoadEvent(myfunction);

= Integrating to your own app

A number of helper methods are  exposed by adding the following to your application_controller.rb
    
    require 'semi_static/sign_in'
    include SignIn
    helper SemiStatic::SiteHelper

In your controllers you can then for example use authenticate_admin!

    before_filter :authenticate_admin!, :except => [ :new, :create ]

= Examples

http://quantum-websites.com/info/portfolio
