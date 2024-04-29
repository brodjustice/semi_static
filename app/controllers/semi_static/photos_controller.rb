require_dependency "semi_static/application_controller"

module SemiStatic
  class PhotosController < ApplicationController

    require 'semi_static/general'
    include General
    include EntriesHelper

    before_action :authenticate_for_semi_static!, :except => [ :show, :index ]
  
    # Caching the show page seems to cause some problems when flicking through the
    # gallery with js. Since the js/ajax is so light anyway we have stopped caching
    # the photo pages js until we are clear about the problem.
    # caches_page :show, :if => Proc.new{|c| c.request.format.html? && !semi_static_admin?}
  
    # GET /photos
    # GET /photos.json
    def index

      layout = 'semi_static_application'
      template = 'semi_static/photos/index'

      if params[:entry_id].present?
        @obj = @entry = Entry.find(params[:entry_id])
        @photos = @obj.photos
      elsif params[:gallery_id].present?
        if semi_static_admin?
          if params[:gallery_id] == 'nil'
            # Admin wants a list of the photos with no Gallery assigned
            @photos = Photo.without_gallery
            layout = 'semi_static_dashboards'
            template = 'semi_static/photos/admin_list_index'
          else
            # Admin wants a list of photos from a specific Gallery
            @obj = @gallery = Gallery.find_by(:id => params[:gallery_id])
          end
        else
          @obj = @gallery = Gallery.visible.find_by(id => params[:gallery_id])
        end
        @photos ||= @obj.photos
      elsif params[:tag_id].present?
        @tag, @seo = Seo.photos(params[:tag_id], I18n.locale) 
      else
        if semi_static_admin?
          @photos = Photo.all
          layout = 'semi_static_dashboards'
          template = 'semi_static/photos/admin_list_index'
        else
          # Nothing else left but to try the predefined Gallery Tag
          @tag = Tag.predefined(I18n.locale, 'Gallery').first
          @tag ? (@seo = @tag.seo) : (raise ActiveRecord::RecordNotFound)
        end
      end

      @galleries = Gallery.locale(I18n.locale).visible
      @selection = 'Gallery'
      @entries = @tag&.entries

      respond_to do |format|
        format.html { render :template => template, :layout => layout }
        format.js { render :template => 'semi_static/photos/admin_entry_photos' }
      end
    end
  
    # GET /photos/1
    # GET /photos/1.json
    def show
      template = 'semi_static/photos/show'
      @photo = Photo.find(params[:id])
      unless @photo.hidden
        if params[:popup].present?
          #
          # Popups and carousels can be in none 'public' or 'hidden' galleries, even
          # though such photos are not protected by authetication and the webserver
          # will display them if you have the specific URL. So likewise if
          # the popup param is present just send the photo js anyway regardless
          # if it is public.
          #
          @photo = Photo.find(params[:id])
          @pixel_ratio = params[:pratio].to_i || 1
          @popup_style = popup_style(@photo, @pixel_ratio)
          @caption = @photo.description
          template = "semi_static/photos/popup"
        elsif @photo.public?
          @selection = 'Gallery'
          @title = @photo.title
        else
          raise ActiveRecord::RecordNotFound
        end
  
        if !params[:popup].present? || @photo.carousel
          @previous, @next = @photo.neighbour_ids
          @previous = Photo.find(@previous)
          @next = Photo.find(@next)
        end
      else
        raise ActiveRecord::RecordNotFound
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
      @photo = Photo.new(photo_params)
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
      @photo = Photo.new(photo_params)
  
      respond_to do |format|
        if @photo.save
          expire_page_cache(@photo)
          unless @photo.notice.blank?
            flash[:notice] = @photo.notice
          end
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
        if @photo.update_attributes(photo_params)
          expire_page_cache(@photo)
          unless @photo.notice.blank?
            flash[:notice] = @photo.notice
          end
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
        format.js
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.fetch(:photo, {}).permit(:title, :description, :img, :home_page, :position,
        :entry_id, :gallery_id, :gallery_control, :locale, :popup, :carousel, :hidden)
    end
  end
end
