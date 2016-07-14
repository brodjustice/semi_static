  require_dependency "semi_static/application_controller"
  
  module SemiStatic
    class SeosController < ApplicationController

    require 'semi_static/general'
    include General
  
    before_filter :authenticate_for_semi_static!
    before_filter :set_return_path
  
    layout 'semi_static_dashboards'
  
    # GET /seos
    # GET /seos.json
    def index
      @seos = Seo.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @seos }
      end
    end
  
    # GET /seos/1
    # GET /seos/1.json
    def show
      @seo = Seo.find(params[:id])
  
      respond_to do |format|
        format.html { render :layout => 'semi_static_application' }
        format.json { render :json => @seo }
      end
    end
  
    # GET /seos/new
    # GET /seos/new.json
    def new
      @seo = Seo.new_from_master(find_seoable)

      respond_to do |format|
        format.html # new.html.erb
        format.js
        format.json { render :json => @seo }
      end
    end
  
    # GET /seos/1/edit
    def edit
      @seo = Seo.find(params[:id])
      if params[:master].present?
        @seo.to_master
      end
      @photos_without_caption = (@seo.seoable.is_a?(Entry) ? @seo.seoable.photos.without_caption : [])

      respond_to do |format|
        format.html { redirect_to params[:return] || seos_path }
        format.js
      end
    end
  
    # POST /seos
    # POST /seos.json
    def create
      @seoable = find_seoable
      @seo = @seoable.seo = Seo.new(params[:seo])
  
      respond_to do |format|
        if @seo.save
          expire_page_cache(@seoable)
          format.html { redirect_to params[:return] || seos_path }
          format.json { render :json => @seo, :status => :created, :location => @seo }
        else
          format.html { render :action => "new" }
          format.json { render :json => @seo.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # PUT /seos/1
    # PUT /seos/1.json
    def update
      @seo = Seo.find(params[:id])
  
      respond_to do |format|
        if @seo.update_attributes(params[:seo])
          expire_page_cache(@seoable)
          format.html { redirect_to params[:return] || url_for(:controller => @seo.seoable.class.to_s.underscore.pluralize, :action => :index), :notice => 'SEO meta tags updated' }
          format.json { head :no_content }
        else
          format.html { redirect_to seos_path, :notice => 'ERROR: SEO tags not updated. ' + @seo.errors.full_messages.join(', ') }
          format.json { render :json => @seo.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # DELETE /seos/1
    # DELETE /seos/1.json
    def destroy
      @seo = Seo.find(params[:id])
      @seoable = @seo.seoable
      @seo.destroy
  
      respond_to do |format|
        format.html { redirect_to edit_polymorphic_url(@seoable) }
        format.json { head :no_content }
      end
    end

    private

    def set_return_path
      @return = params[:return]
    end

    def find_seoable
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
