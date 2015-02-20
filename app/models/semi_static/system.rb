module SemiStatic
  class System
    # This model has no DB table, and in Rails 3 we can pick and choose 
    # our ActiveModel modules. Nice.
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include ActiveModel::Conversion
    extend ActiveModel::Naming
  
    include Pages
  
    ES_BIN = '/usr/share/elasticsearch/bin/elasticsearch'
    ES_PID_DIR = '/tmp/pids'
  
    # This code mainly deals with starting up the elastic-search service and re-indexing. Our approach is to see
    # if there is a system-wide elastic search installed in /usr/share/elasticsearch/bin/elasticsearch. We will
    # not use the binary in the ./vendor directory as we assume that there are a number of Rails apps
    # sharing the search engine.
  
    def self.cmd(cmd)
      self.send(cmd)
    end
  
    def self.search_reindex(*args)
      if search_daemon_running?
        Entry.import
        Photo.import
      else
        false
      end
    end

    def self.generate_sitemap(*args)
      l = args.last
      pages = ['/site/imprint']
      pages.concat(Tag.locale(l).select{|i| i.sitemappable })
      pages.concat(Entry.unmerged.locale(l).select{|i| i.sitemappable })
      pages.concat(Photo.all.select{|i| i.sitemappable })
      pages.concat(Reference.all.select{|i| i.sitemappable })
      pages
    end

    # These things should never happen, but sometimes on a development system they will
    def self.clean_up(*args)
      Entry.all{|e| e.destroy if e.tag.nil?}
      Product.all{|p| p.destroy if p.entry.nil?}
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

    def self.search_daemon(state)
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
