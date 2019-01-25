= SemiStatic

A Rails 5 Engine to get you quickly started with a fast, cached, static website. There is a small CRM so
you can dynamically add content hence the name 'semi-static'. The HTML site should load very quickly on
mobile and desktop devices, and should get a 100% rating on Google pagespeed.

Some tricks that are used to get the fast performance:

1. No javascript on most pages, animations via HTML5
2. Most images in sprite form
3. Home page fonts loaded in-line
4. Home page css loaded in-line
5. HDPI image support via massive compression
6. Full page cacheing whenever possible, with full multi-locale support
7. Option to pre-build gzipped static pages

The current version runs only on POstgreSQL, but you should be able to modify it to run with other databases
without to much effort.

= Install for development

Assuming you want to start with a clean applicaion, then first create your rails application:

Create your new rails application, for example using the postgres DB:

	# rails new myapp -d postgresql

Change your working directory to your Rails app and create the database with:

	# rails db:create

Now add semi-static. Edit the Gemfile to include the semi-static gem/engine:

        gem 'semi_static', :git => 'https://github.com/brodjustice/semi_static.git', :branch => 'rails_v5'

Run the bundler to install the semi-static Rails Engine:

	# bundle install

Run the semi-static install generator. Semi-static needs some authentication and has so far only been tested with the Devise gem. If this generator finds Devise or even a database table called 'users', then it will not try to set up authentication. If it does not find authentication it will ask you if you want to set it up, and then take you through the process of setting up Devise with a single administrator account.

	# rails g semi_static:install

You are finished, start your app:

	# rails s

= Install for production

With rails 5 your app will need a js runtime for the development environment. So for example, make sure this line is uncommented in your 'Gemfile':

	gem 'mini_racer', platforms: :ruby

= Browser support

All modern browsers and IE >= 10 should be supported.

= Configuration

The minimal configuration will require you to edit the 'config/initializers/semi_static.rb' file. Edit that file to
suit your configuration. Thereafter you can customize the css files and overwrite the views to customize as much as
you want.

= Testing

	# rails test

= Content

The initial admin sign in email and password can by found in db/seeds.rb. Use this to sign in and start adding your content.
Note: seeds.rb is created by the generator, so you must have run this first as decribed above. Also, beware of then checking the seed.rb into a repository without deleting the password as this will expose your Admin account.

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

= Uploaded Images

SemiStatic uses the Paperclip gem to resize images. The Paperclip gem itself requires Imagemagick, if not already installed on your system install it with:

    sudo apt-get install imagemagick

Some SemiStatic image styles may change. If you are having trouble with the quality of the uploaded images, then you can reprocess them to the latest version of the SemiStatic styles with:

    rake paperclip:refresh CLASS=SemiStatic::Photo

= ElasticSearch

The elasticsearch gem is automatically installed, but you will need access to an elasticsearch server. We have tested against elasticsearch 5.6.4. On debian you can install this elasticsearch version locally with:

```
# wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.2.deb
# sudo dpkg -i elasticsearch-6.4.2.deb
```

Configure elasticsearch and start it with:

```
# sudo /etc/init.d/elasticsearch start
```

Assuming the ElasticSearch engine is running locally, you can check your search indexes with:

```
# curl 'localhost:9200/_cat/indices?v'
```

You can delete an index with:

```
# curl -X DELETE "localhost:9200/my_index_name"
```

= Integrating to your own app

A number of helper methods are  exposed by adding the following to your application_controller.rb
    
    require 'semi_static/sign_in'
    include SignIn
    helper SemiStatic::SiteHelper

In your controllers you can then for example use authenticate_admin!

    before_action :authenticate_admin!, :except => [ :new, :create ]

= Rake task for non digested assets

The goal of this engine is to privide a basis fo a CMS, and furthermore a CMS where pure HTML will often be used. Since Rails 4 the assets
no longer have a non-digested version. This means that, for example, if you are writing pure HTML like the following, it will fail:

        <img src='assets/my-image.jpg'>

This HTML will not find the image because Rails will only provide assets with a fingerprint/digest, i.e.

        assets/my-image-14d1be2ff7ec4cd54bce852edaa6d9b03fff5a773f9f4b1550393f9228e9e41e.jpg

The HTML will have no way of knowing what the fingerprint is. To fix this SemiStatic provides a task that will provide a path to your assets without the fingerprint:

        # rails semi_static:non_digested_assets

= Examples

http://quantum-websites.com/info/portfolio
