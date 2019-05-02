require 'aasm'

module SemiStatic
  class Order < ApplicationRecord

    # We use the aasm state machine to change the status of the order (cart)
    include AASM

    has_many :order_items

    # Customer details are added to the order only once the order
    # is complete, so make them optional.
    belongs_to :customer, :optional => true

    before_save :update_subtotal
    before_save :consolidate_items

    accepts_nested_attributes_for :customer

    # Define the states and transitions for the order (cart)
    aasm :column => 'order_status' do
      state :empty, :initial => true
      state :populated
      state :payment_pending do
        validates_presence_of :customer_id
      end
      state :card_payment_pending do
        validates_presence_of :customer_id
      end
      state :payment_pending
      state :paid do
        # Would need to clear the cart cookie, but this is
        # something we do in the controller.
      end
      state :shipped
      state :cancelled

      #
      # Add a new OrderItem
      #
      # Note: it's tempting to add a state after method like
      #   event :add, :after => :consolidate_items do ...
      # but calling consolidate_items will stop the order status
      # from being updated. So we keep the consolidate_items
      # as a before save action outside the state machine
      #
      event :add do
        transitions :from => [:populated, :empty, :card_payment_pending, :manual_payment_pending], :to => :populated
      end

      event :pay do
        transitions :from => :manual_payment_pending, :to => :paid
      end

      event :next_step do
        transitions :from => :empty, :to => :populated

        # This is the registration event, after it completes it checks the payment method
        transitions :from => :populated, :to => :card_payment_pending, :guard => :pay_by_credit_card?
        transitions :from => :populated, :to => :manual_payment_pending, :after => :send_email

        # This is the payment event
        transitions :from => :card_payment_pending, :to => :paid
        transitions :from => :manual_payment_pending, :to => :paid
      end
    end

    # 
    # Once the order is :registered, the next step depends on the SemiStatic.config.payment_strategy.
    # If the strategy is :stripe then we need to call the stripe API to collect payment. Otherwise
    # we assume it is :email and just send the email out for payment to be processed manually.
    # 
    def pay_by_credit_card?
      SemiStatic::Engine.config.payment_strategy == :stripe
    end

    def send_email
      SemiStatic::OrderMailer.order_notification(self).deliver
    end

    def subtotal
      order_items.collect { |oi| oi.valid? ? (oi.quantity * oi.unit_price.to_i) : 0 }.sum
    end

    def subtotal_in_cents
      subtotal * 100
    end

    def total_items
      self.order_items.collect{|oi| oi.quantity}.sum
    end


    #
    # Find order_item duplicates and group together
    #
    def consolidate_items

      return if self.order_items.empty?

      quantity = 0

      # There may be order_items that have had their product deleted since the last visit
      self.order_items.select{|oi| oi.product.nil? }.each{|oi| oi.destroy }

      # Order (i.e. arrange) the items according to their product ID
      self.order_items.order!(:product_id)

      # Make sure all items are saved
      self.order_items.select{|oi| oi.id.nil? }.each{|oi|
         oi.save
      }

      self.order_items.collect{|oi| oi.product_id}.uniq.each{|prod_id|

        # Get the total quantity for this product_id
        quantity = self.order_items.where(:product_id => prod_id).collect{|oi| oi.quantity}.sum

        # Find the first order item in with this product_id
        if consolidated_order_item = self.order_items.where(:product_id => prod_id).first

          # Set that order item to represent the total quantity for this product_id
          consolidated_order_item.quantity = quantity.to_i
          consolidated_order_item.save

          # Delete all other order items except the new consolidated one with the total
          self.order_items.where(:product_id => prod_id).where.not(:id => consolidated_order_item.id).delete_all
        end
      }
    end

    private

    def update_subtotal
      self[:subtotal] = subtotal
    end
  end
end
