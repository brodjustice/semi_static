module SemiStatic
  class Link < ApplicationRecord
    include Pages

    # For reference
    #
    # attr_accessible :name, :position, :url, :new_window

    belongs_to :fcol

    default_scope { order(position: :asc) }

  end
end
