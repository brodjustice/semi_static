module SemiStatic
  class Product < ApplicationRecord
    belongs_to :entry, :optional => true

    has_many :order_items

    has_one_attached :img

    validates :price, :numericality => true, :allow_nil => false

    before_save :strip_whitespace

    #
    # Make sure whitespace is stripped before saving price else
    # some services (eg. Stripe) will complain
    #
    def strip_whitespace
      self.price = self.price.strip unless self.price.nil?
    end
  end
end
