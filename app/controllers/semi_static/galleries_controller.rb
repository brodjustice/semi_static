require_dependency "semi_static/application_controller"

module SemiStatic
  class GalleriesController < ApplicationController

    require 'semi_static/general'
    include General

    before_action :authenticate_for_semi_static!, :except => [:show]

    layout 'semi_static_dashboards'

    # If we get here as an admin then we are trying to manage the SemiStatic
    # Galleries and Photos. If not we are just trying to get a look at the
    # public photo gallery which is constructed from various Galaries and
    # Photos
    #
    # GET /galleries
    # GET /galleries.json
    def index
      @galleries = Gallery.all
      @photos_without_gallery = Photo.without_gallery
      layout = 'semi_static_dashboards'
      template = 'semi_static/galleries/index'
  
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
      @gallery = Gallery.new(gallery_params)
  
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
        if @gallery.update_attributes(gallery_params)
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

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def gallery_params
      params.fetch(:gallery, {}).permit(:title, :sub_title, :description, :public, :locale, :position)
    end
  end
end
