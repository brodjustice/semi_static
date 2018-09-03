module SemiStatic
  class ClickAd < ActiveRecord::Base

    # For reference
    #
    # attr_accessible :client, :url

    belongs_to :entry, :optional => true
  end
end
