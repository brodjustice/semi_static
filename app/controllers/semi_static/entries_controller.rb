  require_dependency "semi_static/application_controller"
  
  module SemiStatic
    class EntriesController < ApplicationController
  
    before_filter :authenticate_for_semi_static!,  :except => [ :show, :search, :index ]
  
    caches_page :show
  
    layout 'semi_static_dashboards'
  
    # GET /entries
    # GET /entries.json
    def index
      template = '/semi_static/entries/index'; layout = 'semi_static_dashboards';
      if params[:docs].present?
        template = '/semi_static/entries/documents'; layout = 'semi_static_application';
        @tag = params[:tag_id].present? ? Tag.find(params[:tag_id]) : Tag.for_documents(I18n.locale)
        @entries = Entry.for_documents_tag
      else authenticate_for_semi_static!
        if params[:tag_id].present?
          @tag = Tag.find(params[:tag_id])
          @entries = @tag.entries
        else
          @entries = Entry.unscoped.order(:locale, :tag_id, :position).exclude_newsletters
          @newsletter_entries = Entry.unscoped.for_newsletters
        end
      end
      respond_to do |format|
        format.html { render :template => template, :layout => layout }
        format.json { render :json => @entries }
        format.js
      end
    end
  
    # GET /articles/search
    def search
      if params[:q].present?
        @entries = Entry.search(params[:q]).records
        @query = params[:q]
        template = 'semi_static/entries/results'
      else
        template = 'semi_static/entries/search'
      end
  
      render template: template, layout: 'semi_static_application'
    end
  
  
    # GET /entries/1
    # GET /entries/1.json
    def show
      @entry = Entry.find(params[:id])
      @tag = @entry.tag
      @title = @entry.title
      @seo = @entry.seo
  
      respond_to do |format|
        format.html { render :layout => 'semi_static_application' }
        format.json { render :json => @entry }
      end
    end
  
    # GET /entries/new
    # GET /entries/new.json
    def new
      @entry = Entry.new
      if params[:master].present?
        master = Entry.find(params[:master])
        @entry = master.dup
        @entry.master_entry = master
      elsif params[:newsletter]
        @newsletter = Newsletter.find(params[:newsletter])
        @entry.tag = @newsletter.tag
      end
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @entry }
      end
    end
  
    # GET /entries/1/edit
    def edit
      @entry = Entry.find(params[:id])
    end
  
    # POST /entries
    # POST /entries.json
    def create
      if params[:newsletter_id]
        nl = SemiStatic::Newsletter.find(params[:newsletter_id])
        @entry = nl.tag.entries.create(params[:entry])
      else
        @entry = Entry.new(params[:entry])
      end

  
      respond_to do |format|
        if params[:preview]
          format.js { render 'preview'}
        elsif @entry.save
          format.html { redirect_to entries_path }
          format.json { render :json => @entry, :status => :created, :location => @entry }
        else
          format.html { render :action => "new" }
          format.json { render :json => @entry.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # PUT /entries/1
    # PUT /entries/1.json
    def update
      @entry = Entry.find(params[:id])

      respond_to do |format|
        if params[:preview] && (@entry.attributes = params[:entry])
          format.js { render 'preview'}
        elsif @entry.update_attributes(params[:entry])
          format.html { redirect_to entries_path }
          format.js
        else
          format.html { render :action => "edit" }
          format.js
          format.json { render :json => @entry.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # DELETE /entries/1
    # DELETE /entries/1.json
    def destroy
      @entry = Entry.find(params[:id])
      @entry.destroy
  
      respond_to do |format|
        format.html { redirect_to entries_url }
        format.json { head :no_content }
      end
    end
  end
end
