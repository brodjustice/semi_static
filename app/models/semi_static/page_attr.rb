module SemiStatic
  class PageAttr < ActiveRecord::Base
    # All ruby object have attributes of course, but these are
    # attributes that can be added dynamically to pages (entries and tags)
    attr_accessible :attr_key, :attr_value

    belongs_to :page_attrable, polymorphic: true

    validates :attr_key, :uniqueness => {:scope => [:page_attrable_type, :page_attrable_id]}
  end
end
