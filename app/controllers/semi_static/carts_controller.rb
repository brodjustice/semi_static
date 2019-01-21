require_dependency "semi_static/application_controller"

module SemiStatic
  class CartsController < ApplicationController

    before_action :authenticate_for_semi_static!,  :except => [:show, :edit, :update]

    layout 'semi_static_full'

    def show
      @order_items = current_order.order_items
      @order = current_order
      respond_to do |format|
        #
        # We require the layout that includes jquery
        #
        format.html { render :layout=> 'semi_static_full' }
        format.js
      end
    end

    #
    # The AASM State Machine will manage the status of the order for us, changing the 'order_status' attribute
    # so that we can use it to select the correct template. The only time we have do a check of the status in
    # the conttoller is when the order_status it is :payment_pending or :paid, in which case we need to remove
    # the cart cookie.
    #
    def edit
      @order = current_order
      @customer = @order.customer || @order.build_customer
      if ['manual_payment_pending', 'paid'].include?(@order.order_status)
        session.delete :order_id
      end
      render :layout=> 'semi_static_full', :template => "semi_static/carts/status/#{@order.order_status}"
    end

    #
    # The update action changes the cart (Order) status using the AASM state machine
    #
    def update
      @order = current_order
      if @order.update_attributes(order_params) && @order.next_step && @order.save
        redirect_to edit_cart_path
      else
        render :layout=> 'semi_static_full', :template => "semi_static/carts/status/#{@order.order_status}"
      end
    end

    #
    # Display the orders
    def index
      @orders = Order.all
      respond_to do |format|
        format.html { render :layout=> 'semi_static_dashboards' }
        format.js
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.fetch(:order, {}).permit(:customer_attributes => 
        [:name, :surname, :company, :position, :phone, :email])
    end

  end
end
