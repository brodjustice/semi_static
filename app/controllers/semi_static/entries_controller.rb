  require_dependency "semi_static/application_controller"
  
  module SemiStatic
    class EntriesController < ApplicationController
  
    before_filter :authenticate_user!, :class => SemiStatic::Entry, :except => [ :show, :search ]
  
    caches_page :show, :index
  
    layout 'semi_static_dashboards'
  
    # GET /entries
    # GET /entries.json
    def index
      @entries = Entry.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @entries }
      end
    end
  
    # GET /articles/search
    def search
      @entries = Entry.search(params[:q]).records
      @query = params[:q]
  
      render action: "search", layout: 'semi_static_application'
    end
  
  
    # GET /entries/1
    # GET /entries/1.json
    def show
      @entry = Entry.find(params[:id])
      @tag = @entry.tag
      @title = @entry.title
  
      respond_to do |format|
        format.html { render :layout => 'semi_static_application' }
        format.json { render :json => @entry }
      end
    end
  
    # GET /entries/new
    # GET /entries/new.json
    def new
      @entry = Entry.new
  
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
      @entry = Entry.new(params[:entry])
  
      respond_to do |format|
        if @entry.save
          format.html { redirect_to @entry }
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
        if @entry.update_attributes(params[:entry])
          format.html { redirect_to @entry }
          format.json { head :no_content }
        else
          format.html { render :action => "edit" }
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
