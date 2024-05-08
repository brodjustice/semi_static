require_dependency "semi_static/application_controller"

module SemiStatic
  class ProductsController < ApplicationController

    before_action :authenticate_for_semi_static!, :except => :show
    before_action :set_return_path

    layout 'semi_static_dashboards'

    # GET /products
    # GET /products.json
    def index
      @products = Product.all
      
      # This only needed if we have a public view of the products, but this
      # index is for the dasboard only
      # @order_item = current_order.order_items.new

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @products }
      end
    end
  
    #
    # The show AJAX updates the page to add the cart buttons
    #
    def show
      # The AJAX call may not include a valid product id, the id is
      # part of the HTML in the page
      @product = Product.find_by(:id => params[:id])

      # order_item is only needed for the AJAX call for an add-to-cart button
      @order_item = current_order.order_items.build
  
      respond_to do |format|
        format.html # show.html.haml
        format.js # show.js.haml provides only an add-to-cart button
      end
    end
  
    def new
      if params[:entry_id]
        @entry = Entry.find(params[:entry_id])
        @product = @entry.build_product(:name => @entry.title,
          :description => @entry.image_caption, :currency => SemiStatic::Engine.config.default_currency)
      else
        @product = Product.new(:currency => SemiStatic::Engine.config.default_currency)
      end
  
      respond_to do |format|
        format.html # new.html.erb
        format.js
        format.json { render json: @product }
      end
    end
  
    # GET /products/1/edit
    def edit
      @product = Product.find(params[:id])

      respond_to do |format|
        format.html
        format.js
      end
    end
  
    # POST /products
    # POST /products.json
    def create
      if params[:entry_id]
        @entry = Entry.find(params[:entry_id])
        @product = @entry.build_product(product_params)
      else
        @product = Product.new(product_params)
      end
  
      respond_to do |format|
        if @product.save
          format.html { redirect_to params[:return] || products_path, notice: 'Product was successfully created.' }
          format.json { render json: @product, status: :created, location: @product }
        else
          format.html { render action: "new" }
          format.json { render json: @product.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /products/1
    # PUT /products/1.json
    def update
      @product = Product.find(params[:id])
  
      respond_to do |format|
        if @product.update_attributes(product_params)
          format.html { redirect_to params[:return] || products_path, notice: 'Product was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @product.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /products/1
    # DELETE /products/1.json
    def destroy
      @product = Product.find(params[:id])
      @product.destroy
  
      respond_to do |format|
        format.html { redirect_to products_url }
        format.json { head :no_content }
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.fetch(:product, {}).permit(:name, :description, :color, :height, :depth, :width,
        :weight, :price, :currency, :inventory_level, :entry_id, :active, :orderable, :img,
        :override_nil_price,
      )
    end

    def set_return_path
      @return = params[:return]
    end
  end
end
