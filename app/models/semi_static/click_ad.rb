module SemiStatic
  class ClickAd < ActiveRecord::Base
    attr_accessible :client, :url

    belongs_to :entry
  end
end
