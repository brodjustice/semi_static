require_dependency "semi_static/application_controller"

module SemiStatic
  class OrderItemsController < ApplicationController

    # 
    # In the SemiStatic Entry HTML we only have create (POST), no update
    # (PUT/PATCH).  Create always adds another order item to the
    # current_order. This is then sent to a consolidate items method to make
    # sure there is only one order_item per product. This method saves
    # a lot of time at the front-end updating the AJAX to be POST or
    # PATCH depending of the order_item status.
    #
    def create
      @order = current_order
      if @order.may_add?
        @order_item = @order.order_items.new(order_item_params)
      else
        @order.errors.add(:base, "Cannot add items to cart: Cart is #{@order.order_status}")
      end

      #
      # Note: Because of the AASM state machine and validations the order of these actions below
      # is meaninful. Notably, the @order.save will add errors to the @order.item. So the
      # @order.item.errors.empty? will always be true if checked before @order.save. The 
      # @order.add must come last and only be called if there are no errors since it will
      # cause the order to be sorted and saved regardless of errors. Finally the @order
      # must be saved yet again to make sure the new order_status is saved following
      # the AASM call to @order.add
      #
      @order.save
      session[:order_id] = @order.id

      respond_to do |format|
        if @order.errors.empty? && @order_item.errors.empty? && @order.add && @order.save
          format.html 
          format.js
        else
          format.html
          format.js { render template: 'semi_static/order_items/error' }
        end
      end
    end
  
    # 
    # Not used in the SemiStatic entry but is called from the Cart
    # page when updating the product quantities in each order_item.
    #
    def update
      @order = current_order
      if @order.may_add?
        @order_item = @order.order_items.find(params[:id])
        @order_item.update_attributes(order_item_params)
        @order_items = @order.order_items
      end
    end
  
    def destroy

      @order = current_order
      template = 'error'
      @order_item = @order.order_items.where(:id => params[:id]).first

      if @order.may_add?

        # Handle the case where order_item was not found
        @order_item_id = params[:id]
        @order_item && @order_item.destroy

        @order_items = @order.order_items
        template = 'destroy'
      else
        @order_item.errors.add(:base, "Cannot delete order item - Order status is #{@order_item.order.order_status}")
      end
      respond_to do |format|
        format.js { render template: "semi_static/order_items/#{template}"}
      end
    end

    private
 
    def order_item_params
      params.require(:order_item).permit(:quantity, :product_id)
    end
  end
end
