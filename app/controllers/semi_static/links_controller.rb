require_dependency "semi_static/application_controller"

module SemiStatic
  class LinksController < ApplicationController

    require 'semi_static/general'
    include General

    before_action :authenticate_for_semi_static!

    layout 'semi_static_dashboards'
  
    # GET /links
    # GET /links.json
    def index
      @links = Link.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @links }
      end
    end
  
    # GET /links/1
    # GET /links/1.json
    def show
      @link = Link.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @link }
      end
    end
  
    # GET /links/new
    # GET /links/new.json
    def new
      @fcol = Fcol.find(params[:fcol_id])
      @link = @fcol.links.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @link }
      end
    end
  
    # GET /links/1/edit
    def edit
      @fcol = Fcol.find(params[:fcol_id])
      @link = @fcol.links.find(params[:id])
    end
  
    # POST /links
    # POST /links.json
    def create
      @fcol = Fcol.find(params[:fcol_id])
      @link = @fcol.links.new(link_params)
  
      respond_to do |format|
        if @link.save
          expire_page_cache(@link)
          format.html { redirect_to fcols_path, notice: 'Footer link was successfully created.' }
          format.json { render json: @link, status: :created, location: @link }
        else
          format.html { render action: "new" }
          format.json { render json: @link.errors, status: :unprocessable_entity }
        end
      end
    end
    # PUT /links/1
    # PUT /links/1.json
    def update
      @link = Link.find(params[:id])
  
      respond_to do |format|
        if @link.update_attributes(link_params)
          expire_page_cache(@link)
          format.html { redirect_to fcols_path, notice: 'Footer link was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @link.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /links/1
    # DELETE /links/1.json
    def destroy
      @link = Link.find(params[:id])
      @link.destroy
  
      respond_to do |format|
        format.html { redirect_to fcols_url }
        format.json { head :no_content }
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def link_params
      params.fetch(:link, {}).permit(:name, :position, :url, :new_window)
    end
  end
end
