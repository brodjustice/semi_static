require 'net/http'

module SemiStatic
  class System
    # This model has no DB table, and in Rails 3 we can pick and choose 
    # our ActiveModel modules. Nice.
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include ActiveModel::Conversion
    extend ActiveModel::Naming
  
    include Pages
  
    ES_BIN = SemiStatic::Engine.config.elasticsearch
    ES_PID_DIR = '/tmp/pids'
  
    # This code mainly deals with starting up the elastic-search service and re-indexing. Our approach is to see
    # if there is a system-wide elastic search installed in /usr/share/elasticsearch/bin/elasticsearch. We will
    # not use the binary in the ./vendor directory as we assume that there are a number of Rails apps
    # sharing the search engine.
    # All data can be deleted with (careful now!): curl -XDELETE 'http://localhost:9200/_all'
    # If you need to create an index you can do this manually with: curl -XPUT 'http://localhost:9200/myindexname/'
  
    def self.cmd(cmd)
      self.send(cmd)
    end

    def self.partial_description(*args)
      c = " "
        if SemiStatic::Engine.config.open_partials[args.first]
        path = File.dirname Rails.root.join('app', 'views') + SemiStatic::Engine.config.open_partials[args.first]
        filename = "_#{SemiStatic::Engine.config.open_partials[args.first].split('/').last}.html.haml"
        if File.exist? path + '/' + filename
          File.open(path + '/' + filename) do |file|
            while (line = file.gets)
              c += line.split('-#').count == 2 ? line.split('-#').last.to_s.gsub!(/\n/, "\r ") : ''
            end
          end
        end
      end
      c
    end
  
    def self.search_reindex(*args)
      if search_daemon_running?
        Entry.__elasticsearch__.create_index! force: true
        Entry.import
        Photo.import
      else
        false
      end
    end

    def self.generate_sitemap(*args)
      l = args.last
      pages = ['/site/imprint-credits']
      # Add contact page if it's not already predefined
      if Tag.predefined(l, 'Contact').empty?
        pages << '/contacts/new'
      end
      pages.concat(Tag.locale(l).select{|i| i.sitemappable && !i.subscriber })
      pages.concat(Entry.unmerged.locale(l).select{|i| i.sitemappable && !i.subscriber_content })
      pages.concat(Photo.locale(l).select{|i| i.sitemappable })
      pages.concat(Reference.all.select{|i| i.sitemappable })
      pages
    end

    def self.generate_static_pages(*args)
      # Use the sitemap generator to get all the pages for the last arg (locale)
      generate_sitemap(args.last)
    end

    # Need to gzip command installed on system
    def self.load_url(url=nil, locale=nil, *args)
      s = true

      uri = URI.parse(url)
      req = Net::HTTP::Get.new(uri.to_s)
      res = Net::HTTP.start(uri.host, uri.port) {|http|
        http.request(req)
      }

      # Could do this with curl like this, but best to use the library
      #
      # url without type extension is considered html by default but if curl
      # does not have an extension then the webserver may see this as a simple
      # text request. So we have to check the extension and if its blank tell
      # curl to set the 'text/html' header 
      #
      # if (html = (uri.path.split('.').count == 1 || uri.path.split('.').last == 'html'))
      #   res = `curl -iH "Accept:text/html" #{url} -o '/dev/null' 2>&1`
      # else
      #   res = `curl #{url} -o '/dev/null' 2>&1`
      # end
      # s = $?.success?

      if (res.code == '200') && !locale.blank?
        path = (uri.path == '/') ? '/index' : uri.path
        file = "#{Rails.public_path}/#{locale.to_s}#{path}.html"
        if File.exist? file
          res = `gzip -c -7 #{file} > #{file}.gz`
        else
          res = 'Server responded 200 OK but could not create static gzipped html version'
          s = false
        end
      else
        res = "Server responded #{res.code}"
        s = false
      end
      [s, url, res]
    end

    # These things should never happen, but sometimes on a development system they will
    def self.clean_up(*args)
      Entry.all{|e| e.destroy if e.tag.nil?}
      Product.all{|p| p.destroy if p.entry.nil?}
      # Get rid of newsletter tags  where the actual newsletter has been deleted
      Tag.select{|t| t.newsletter_id.present? && t.newsletter.nil?}.each{|t| t.destroy}
    end

    # Restart passenger app server (if used)
    def self.passenger_restart(*args)
      `touch #{Rails.root.to_s}/tmp/restart.txt`
      $?.success?
    end
  
    def self.search_daemon_running?
      # Check if the pid file lock exists. Locally we would do:
      #  `test -f #{ENV['PWD']}/tmp/pids/elasticsearch.pid`
      `test -f #{ES_PID_DIR}/elasticsearch.pid`
      $?.success?
    end
  
    def self.expire_cache(*args)
      # We ignore type for now and expire everything
      Pages.expire_site_page_cache
    end

    def self.search_daemon(state, *args)
      if state == 'on'
        if search_daemon_running?
          true
        else
          script_info = `#{ES_BIN} -d -p #{ES_PID_DIR}/elasticsearch.pid &`
          sleep 5.seconds
          `test -f #{ES_PID_DIR}/elasticsearch.pid`
          $?.success?
        end
      elsif state == 'off'
        if search_daemon_running?
          pid = `cat #{ES_PID_DIR}/elasticsearch.pid`
          script_info = `kill -15 #{pid}`
          $?.success?
          # Sleep below causes a delay of course, but since it is normally called
          # by an ajax call which itself is triggered by a checkbox change, it
          # works much better if there is a delay to stop false feedback
          sleep 5.seconds
        else
          true
        end
      end
    end
  end
end
