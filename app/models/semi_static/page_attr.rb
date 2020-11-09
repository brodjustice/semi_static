module SemiStatic
  class PageAttr < ApplicationRecord

    # All ruby objects have attributes of course, but these are
    # attributes that can be added dynamically to pages (entries and tags)
    #
    # attr_accessible :attr_key, :attr_value

    before_save :remove_whitespace

    belongs_to :page_attrable, polymorphic: true

    validates :attr_key, :uniqueness => {:scope => [:page_attrable_type, :page_attrable_id]}

    def remove_whitespace
      self.attr_key&.squish!
    end
  end
end
