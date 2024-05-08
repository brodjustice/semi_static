module SemiStatic
  class Product < ApplicationRecord
    attr_accessor :override_nil_price

    belongs_to :entry, :optional => true

    has_many :order_items

    has_one_attached :img

    validates :price, :numericality => true, :allow_nil => false, :unless => :override_nil_price?

    before_save :strip_whitespace

    #
    # Make sure whitespace is stripped before saving price else
    # some services (eg. Stripe) will complain
    #
    def strip_whitespace
      self.price = self.price.strip unless self.price.nil?
    end

    #
    # Most schema don't accept products without a price, but if the user insists
    # then here is a way to accept no price being shown
    #
    def override_nil_price?
      # It's a checkbox so watch out for '0' value
      override_nil_price && override_nil_price != '0'
    end
  end
end
