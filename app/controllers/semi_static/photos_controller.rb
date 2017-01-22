require_dependency "semi_static/application_controller"

module SemiStatic
  class PhotosController < ApplicationController

    require 'semi_static/general'
    include General

    before_filter :authenticate_for_semi_static!, :except => [ :show, :index ]
  
    # Caching the show page seems to cause some problems when flicking through the
    # gallery with js. Since the js/ajax is so light anyway we have stopped caching
    # the photo pages js until we are clear about the problem.
    # caches_page :show, :if => Proc.new{|c| c.request.format.html? && !semi_static_admin?}
  
    # GET /photos
    # GET /photos.json
    def index

      if params[:entry_id].present?
        @obj = @entry = Entry.find(params[:entry_id])
        @photos = @obj.photos
      elsif params[:gallery_id].present?
        @obj = @gallery = Gallery.find_by_id(params[:gallery_id])
        @photos = @obj.photos
      elsif params[:tag_id].present?
        @tag, @seo = Seo.photos(params[:tag_id], I18n.locale) 
      else
        @tag = Tag.predefined(I18n.locale, 'Gallery').first
        @seo = @tag.seo
      end

      @galleries = Gallery.locale(I18n.locale).visible
      @selection = 'Gallery'
      @entries = @tag && @tag.entries

      layout = 'semi_static_application'
      template = 'semi_static/photos/index'

      respond_to do |format|
        format.html { render :template => template, :layout => layout }
        format.js { render :template => 'semi_static/photos/admin_entry_photos' }
      end
    end
  
    # GET /photos/1
    # GET /photos/1.json
    def show
      template = 'semi_static/photos/show'
      unless params[:popup].present?
        @photo = Photo.visible.find(params[:id])
        @selection = 'Gallery'
        @title = @photo.title
        @previous, @next = @photo.neighbour_ids
        @previous = Photo.find(@previous)
        @next = Photo.find(@next)
      else
        #
        # Popups can be in none 'public' or 'hidden' galleries, even though such
        # photos are not protected by authetication and the webserver if you haver
        # will display them if you have the specific URL
        #
        @photo = Photo.find(params[:id])
        @pixel_ratio = params[:pratio].to_i || 1
        @popup_style = popup_style(@photo, @pixel_ratio)
        @caption = @photo.description
        template = "semi_static/photos/popup"
      end
  
      layout = (semi_static_admin? ? 'semi_static_dashboards' : 'semi_static_full')
  
      respond_to do |format|
        format.html { render :layout => layout }
        format.js { render :template => template }
        format.json { render json: @photo }
      end
    end
  
    # GET /photos/new
    # GET /photos/new.json
    def new
      @photo = Photo.new(params[:photo])
      @entries = Entry.unscoped.order(:locale, :tag_id, :position).exclude_newsletters
      if params[:master].present?
        master = Photo.find(params[:master])
        @photo = master.tidy_dup
      end
  
      respond_to do |format|
        format.html { render :layout => 'semi_static_dashboards' }
        format.json { render json: @photo }
      end
    end
  
    # GET /photos/1/edit
    def edit
      layout = 'semi_static_dashboards'
      @photo = Photo.find(params[:id])
      @entries = Entry.unscoped.order(:locale, :tag_id, :position).exclude_newsletters
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
          expire_page_cache(@photo)
          format.html { redirect_to galleries_path }
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
          expire_page_cache(@photo)
          format.html { redirect_to galleries_path,:notice => 'Photo was successfully updated.' }
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
      expire_page_cache(@photo)
      @photo.destroy
  
      respond_to do |format|
        format.html { redirect_to photos_url }
        format.json { head :no_content }
        format.js
      end
    end

    protected

    # Derives an inline stype for double density popup image based on Photo(p) and pixel ratio (pr)
    # The wierd thing is that the double density image is massively compressed, and is so not as
    # not as many Mbytes as half width (1/4 of the area) version. However, because of the extra pixel
    # density the image still renders better than the single density half width, 1/4 size, version
    def popup_style(p, pr)
      unless p.img_dimensions.blank?
        pr = pr.round
        @width = p.img_dimensions.first.to_i/2
        @height = p.img_dimensions.last.to_i/2
        url = ((pr > 1.5) ? @photo.img.url(:compressed) : @photo.img.url(:half))
        "background-image: url(#{url}); background-size: #{@width}px #{@height}px; width:#{@width}px; height:#{@height}px;"
      else
        "background: url(#{p.img.url}) center center no-repeat; background-size: cover;"
      end
    end

  end
end
