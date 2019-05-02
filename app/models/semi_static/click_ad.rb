module SemiStatic
  class ClickAd < ApplicationRecord

    # For reference
    #
    # attr_accessible :client, :url

    belongs_to :entry, :optional => true
  end
end
