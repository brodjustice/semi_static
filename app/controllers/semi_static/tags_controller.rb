  require_dependency "semi_static/application_controller"
  
  module SemiStatic
    class TagsController < ApplicationController
  
    before_filter :authenticate_for_semi_static!, :except => :show

    caches_page :show
  
    layout 'semi_static_dashboards'
  
    # GET /tags
    # GET /tags.json
    def index
      @tags = Tag.unscoped.order(:locale, :position)
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @tags }
      end
    end
  
    # GET /tags/1
    # GET /tags/1.json
    def show
      # You might want to look for slugs of different locales, especially if these are custom
      # pages. So first look for tag in current locale and if this fails take first matching tag
      @tag = Tag.where(:locale => locale.to_s).find_by_slug(params[:slug]) || Tag.find_by_slug!(params[:slug])

      @title = @tag.name
      @seo = @tag.seo
  
      respond_to do |format|
        format.html { render :layout => 'semi_static_application' }
      end
    end
  
    # GET /tags/new
    # GET /tags/new.json
    def new
      @tag = Tag.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @tag }
      end
    end
  
    # GET /tags/1/edit
    def edit
      @tag = Tag.find(params[:id])
    end
  
    # POST /tags
    # POST /tags.json
    def create
      @tag = Tag.new(params[:tag])
  
      respond_to do |format|
        if @tag.save
          format.html { redirect_to tags_path, :notice => 'Tag was successfully created.' }
          format.json { render :json => @tag, :status => :created, :location => @tag }
        else
          format.html { render :action => "new" }
          format.json { render :json => @tag.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # PUT /tags/1
    # PUT /tags/1.json
    def update
      @tag = Tag.find(params[:id])
  
      respond_to do |format|
        if @tag.update_attributes(params[:tag])
          format.html { redirect_to tags_path, :notice => 'Tag was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render :action => "edit" }
          format.json { render :json => @tag.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # DELETE /tags/1
    # DELETE /tags/1.json
    def destroy
      @tag = Tag.find(params[:id])
      @tag.destroy
  
      respond_to do |format|
        format.html { redirect_to tags_url }
        format.json { head :no_content }
      end
    end
  end
end
