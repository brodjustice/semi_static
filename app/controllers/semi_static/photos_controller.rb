require_dependency "semi_static/application_controller"

module SemiStatic
  class PhotosController < ApplicationController

    # load_and_authorize_resource :class => SemiStatic::Photo, :except => [:index, :new, :show]
    before_filter :authenticate_user!, :class => SemiStatic::Photo, :except => [ :show, :index ]
  
    caches_page :show
  
    # GET /photos
    # GET /photos.json
    def index
      @photos = Photo.all
      @photo = @photos.first
      @selection = 'Gallery'
      @tag = Tag.find_by_id(params[:tag_id])
  
      layout = (current_user ? 'semi_static_dashboards' : 'semi_static_application')
      template = (current_user ? 'semi_static/photos/admin_index' : 'semi_static/photos/index')
  
      respond_to do |format|
        format.html { render :template => template, :layout => layout }
      end
    end
  
    # GET /photos/1
    # GET /photos/1.json
    def show
      @photo = Photo.find(params[:id])
      @selection = 'Gallery'
      @title = @photo.title
      @previous, @next = @photo.neighbour_ids
  
      layout = (current_user ? 'semi_static_dashboards' : 'semi_static_full')
  
      respond_to do |format|
        format.html { render :layout => layout }
        format.js
        format.json { render json: @photo }
      end
    end
  
    # GET /photos/new
    # GET /photos/new.json
    def new
      @photo = Photo.new
  
      respond_to do |format|
        format.html { render :layout => 'semi_static_dashboards' }
        format.json { render json: @photo }
      end
    end
  
    # GET /photos/1/edit
    def edit
      layout = (current_user ? 'semi_static_dashboards' : 'semi_static_application')
      @photo = Photo.find(params[:id])
      respond_to do |format|
        format.html { render :layout => layout }
        format.json { render json: @photo }
      end
    end
  
    # POST /photos
    # POST /photos.json
    def create
      @photo = Photo.new(params[:photo])
  
      respond_to do |format|
        if @photo.save
          format.html { redirect_to photos_path }
          format.json { render json: @photo, status: :created, location: @photo }
        else
          format.html { render action: "new" }
          format.json { render json: @photo.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /photos/1
    # PUT /photos/1.json
    def update
      @photo = Photo.find(params[:id])
  
      respond_to do |format|
        if @photo.update_attributes(params[:photo])
          format.html { redirect_to photos_path }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @photo.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /photos/1
    # DELETE /photos/1.json
    def destroy
      @photo = Photo.find(params[:id])
      @photo.destroy
  
      respond_to do |format|
        format.html { redirect_to photos_url }
        format.json { head :no_content }
      end
    end
  end
end
