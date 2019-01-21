module SemiStatic
  class OrderItem < ApplicationRecord
    belongs_to :product
    belongs_to :order

    validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validate :product_present
    validate :order_present
    validate :check_currency
  
    before_save :finalize

    delegate :currency, :to => :product, :allow_nil => true
  
    def unit_price
      if persisted?
        self[:unit_price]
      else
        product.price
      end
    end
  
    def total_price
      unit_price.to_f * quantity
    end
  
    private
 
    def product_present
      if product.nil?
        errors.add(:product, "is not valid or is not active.")
      end
    end
  
    def order_present
      if order.nil?
        errors.add(:order, "is not a valid order.")
      end
    end
  
    def check_currency
      #
      # If the order currency is not set (i.e. self.order.currency.nil?) or this the first and
      # only order_item in the order (i.e. self.order.order_items.size == 1) then we can set
      # the order currency to be the same as this OrderItem's currency.
      #
      (self.order.currency.nil? || (self.order.order_items.size == 1)) && (self.order.currency = self.currency)
      if self.currency != self.order.currency
        self.errors.add(:base, "Product currency #{self.currency} does not match order currency #{self.order.currency}")
      end
    end

    def finalize
      self[:unit_price] = unit_price
      self[:total_price] = quantity * self[:unit_price].to_f
    end
  end
end
