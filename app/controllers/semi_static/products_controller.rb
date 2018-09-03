require_dependency "semi_static/application_controller"

module SemiStatic
  class ProductsController < ApplicationController

    before_action :authenticate_for_semi_static!
    before_action :set_return_path

    layout 'semi_static_dashboards'

    # GET /products
    # GET /products.json
    def index
      @products = Product.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @products }
      end
    end
  
    # GET /products/1
    # GET /products/1.json
    def show
      @product = Product.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @product }
      end
    end
  
    # GET /products/new
    # GET /products/new.json
    def new
      @entry = Entry.find(params[:entry_id])
      @product = @entry.build_product(:name => @entry.title, :description => @entry.image_caption)
  
      respond_to do |format|
        format.html # new.html.erb
        format.js
        format.json { render json: @product }
      end
    end
  
    # GET /products/1/edit
    def edit
      @entry = Entry.find(params[:entry_id])
      @product = Product.find(params[:id])

      respond_to do |format|
        format.html
        format.js
      end
    end
  
    # POST /products
    # POST /products.json
    def create
      @entry = Entry.find(params[:entry_id])
      @product = @entry.build_product(product_params)
  
      respond_to do |format|
        if @product.save
          format.html { redirect_to params[:return] || entry_product_path(@entry, @product), notice: 'Product was successfully created.' }
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
          format.html { redirect_to params[:return] || entry_product_path(@product.entry, @product), notice: 'Product was successfully updated.' }
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
        :weight, :price, :currency, :inventory_level, :entry_id)
    end

    def set_return_path
      @return = params[:return]
    end
  end
end
