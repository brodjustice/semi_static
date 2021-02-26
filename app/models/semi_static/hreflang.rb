require 'net/http'
require 'uri'

module SemiStatic
  class Hreflang < ApplicationRecord

    belongs_to :seo, :dependent => :destroy

    validate :load_url
    validates :locale, uniqueness: { scope: :seo_id, message: "Can not have duplicate hreflangs with same locale for same webpage" }

    def load_url

      # Check for SSL/https
      ssl = (URI.parse(self.href).scheme == 'https')

      uri = URI.parse(self.href)
      req = Net::HTTP::Get.new(uri.to_s)
      req["User-Agent"] = "SemiStatic"
      if (html = (uri.path.split('.').count == 1 || uri.path.split('.').last == 'html'))
        req["Accept"] = "text/html"
      end

      begin
        res = Net::HTTP.start(uri.host, uri.port, :use_ssl => ssl) {|http|
          http.request(req)
        }

        Net::HTTP.get(URI.parse(self.href))
      rescue => e
        # Not much to do, it failed for one of many reasons 
      end

      if (res&.code != '200') || !html
        errors.add(:href, "URL cannot be loaded")
      end
    end

    def siblings
      self.seo&.hreflangs.select{|hr| !hr.new_record? }
    end

  end
end
