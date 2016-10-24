require_dependency "semi_static/application_controller"

module SemiStatic
  class GalleriesController < ApplicationController

    require 'semi_static/general'
    include General

    before_filter :authenticate_for_semi_static!, :except => [:show, :index]

    # If called but not admin, then the index will create a public
    # cached page (/gallery). However, if called as admin it will 
    # show the dynamic content (/galleries) and should not be
    # cahced.
    caches_page :index, :if => Proc.new { |c| !semi_static_admin? }

    layout 'semi_static_dashboards'

    # If we get here as an admin then we are trying to manage the SemiStatic
    # Galleries and Photos. If not we are just trying to get a look at the
    # public photo gallery which is constructed from various Galaries and
    # Photos, as this action is also pointed at by /gallery in config routes
    #
    # GET /galleries
    # GET /galleries.json
    def index
      if semi_static_admin?
        @galleries = Gallery.all
        @photos_without_gallery = Photo.without_gallery
        layout = 'semi_static_dashboards'
        template = 'semi_static/galleries/index'
      else
        @galleries = Gallery.locale(I18n.locale).visible
        @selection = 'Gallery'
        @tag, @seo = Seo.photos(params[:tag_id], I18n.locale)
        @entries = @tag && @tag.entries
        layout = "semi_static_#{General::LAYOUTS[@tag.layout_select || 0]}"
        template = 'semi_static/photos/index'
      end
  
      respond_to do |format|
        format.html { render :template => template, :layout => layout }
        format.json { render json: @galleries }
      end
    end
  
    # GET /galleries/1
    # GET /galleries/1.json
    def show
      @gallery = Gallery.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @gallery }
      end
    end
  
    # GET /galleries/new
    # GET /galleries/new.json
    def new
      @gallery = Gallery.new(:public => true)
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @gallery }
      end
    end
  
    # GET /galleries/1/edit
    def edit
      @gallery = Gallery.find(params[:id])
    end
  
    # POST /galleries
    # POST /galleries.json
    def create
      @gallery = Gallery.new(params[:gallery])
  
      respond_to do |format|
        if @gallery.save
          format.html { redirect_to galleries_path, notice: 'Gallery was successfully created.' }
          format.json { render json: @gallery, status: :created, location: @gallery }
        else
          format.html { render action: "new" }
          format.json { render json: @gallery.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /galleries/1
    # PUT /galleries/1.json
    def update
      @gallery = Gallery.find(params[:id])
  
      respond_to do |format|
        if @gallery.update_attributes(params[:gallery])
          format.html { redirect_to galleries_path, notice: 'Gallery was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @gallery.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /galleries/1
    # DELETE /galleries/1.json
    def destroy
      @gallery = Gallery.find(params[:id])
      @gallery.destroy
  
      respond_to do |format|
        format.html { redirect_to galleries_url }
        format.json { head :no_content }
      end
    end
  end
end
