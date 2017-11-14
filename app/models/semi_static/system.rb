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

    #
    # Reindex with elasticsearch
    #
    def self.search_reindex(*args)
      Entry.__elasticsearch__.create_index! force: true
      Entry.import
      Photo.import
    end

    # Restart passenger app server (if used)
    def self.passenger_restart(*args)
      `touch #{Rails.root.to_s}/tmp/restart.txt`
      $?.success?
    end
  end
end
