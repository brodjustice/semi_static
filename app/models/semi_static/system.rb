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
              if (line.split('-#').count == 2) && line.split('-#').first.empty?
                c += line.split('-#').last.to_s.gsub!(/\n/, "\r ")
              end
            end
          end
        end
      end
      c
    end

    GOOGLE_API_KEY = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    SEARCH_API_URL = "https://www.googleapis.com/webmasters/v3/sites/siteURL/searchAnalytics/query?key=#{GOOGLE_API_KEY}"

    # Draft code, this will not work with just API key, need OAuth
    def self.load_search_data(*args)
      property = URI.parse(SemiStatic::Engine.config.localeDomains[args.last] + '/')
      uri = URI.parse(SEARCH_API_URL.sub(/siteURL/, CGI.escape(property.to_s)))
      https = Net::HTTP.new('www.googleapis.com', 443)
      https.use_ssl = true
      data = "startDate=2016-01-01&endDate=2016-02-01"
      headers = {'Content-Type' => 'application/json'}
      resp = https.post(uri.request_uri, data, headers)
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
