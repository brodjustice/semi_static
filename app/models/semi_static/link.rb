module SemiStatic
  class Link < ActiveRecord::Base
    include Pages

    attr_accessible :name, :position, :url, :new_window

    belongs_to :fcol

    default_scope {:order('position ASC')}

  end
end
