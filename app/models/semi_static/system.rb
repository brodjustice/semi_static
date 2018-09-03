require 'net/http'

module SemiStatic
  class System
    # This model has no DB table. We can pick and choose 
    # our ActiveModel modules. Nice.
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include ActiveModel::Conversion
    extend ActiveModel::Naming
  
    include Pages
  
    def self.cmd(cmd)
      self.send(cmd)
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
