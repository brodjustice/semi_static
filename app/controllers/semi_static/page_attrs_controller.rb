require_dependency "semi_static/application_controller"

module SemiStatic
  class PageAttrsController < ApplicationController

  before_filter :authenticate_for_semi_static!,  :except => [ :show, :search ]

    def index
      @page_attrs = PageAttr.all
      respond_to do |format|
        format.html{render :layout => 'semi_static_dashboards'}
      end
    end
  
    def show
      @page_attr = PageAttr.find(params[:id])
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @page_attr }
      end
    end
  
    def new
      @page_attrable = find_page_attrable
      @page_attr = @page_attrable.page_attrs.new
      respond_to do |format|
        format.html
        format.js
      end
    end
  
    def edit
      @page_attrable = find_page_attrable
      @page_attr = @page_attrable.page_attrs.find(params[:id])
      respond_to do |format|
        format.html
        format.js
      end
    end
  
    def create
      @page_attrable = find_page_attrable
      @page_attr = @page_attrable.page_attrs.new(params[:page_attr])
      respond_to do |format|
        if @page_attr.save
          format.html {
            redirect_to (params[:return].present? ? params[:return] : edit_polymorphic_path(@page_attrable)), notice: 'Page Attribute was successfully created.'
          }
          format.json { render json: @page_attr, status: :created, location: @page_attr }
        else
          format.html { render action: "new" }
          format.json { render json: @page_attr.errors, status: :unprocessable_entity }
        end
      end
    end
  
    def update
      @page_attrable = find_page_attrable
      @page_attr = @page_attrable.page_attrs.find(params[:id])
      respond_to do |format|
        if @page_attr.update_attributes(params[:page_attr])
          format.html { redirect_to (params[:return].present? ? params[:return] : edit_polymorphic_path(@page_attrable)), notice: 'Page Attribute was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { redirect_to (params[:return].present? ? params[:return] : edit_polymorphic_path(@page_attrable)), notice: 'ERROR **** Page Attribute was not updated. ****' }
          format.json { render json: @page_attr.errors, status: :unprocessable_entity }
        end
      end
    end
  
    def destroy
      @page_attr = PageAttr.find(params[:id])
      @page_attrable = @page_attr.page_attrable
      @page_attr.destroy
      respond_to do |format|
        format.html { redirect_to edit_polymorphic_path(@page_attrable) }
        format.json { head :no_content }
      end
    end

    private

    def find_page_attrable
      parents = []
      params.each do |k, v|
        if k =~ /(.+)_id$/
          parents.push ('SemiStatic::' + $1.classify).constantize.find(v)
        end
      end
      parents.last
    end

  end
end
