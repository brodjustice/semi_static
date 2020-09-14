require_dependency "semi_static/application_controller"

module SemiStatic
  class BannersController < ApplicationController
    require 'semi_static/general'
    include General

    # before_filter :authenticate_user!, :class => SemiStatic::Banner
    before_action :authenticate_for_semi_static!

    layout 'semi_static_dashboards'

    # GET /banners
    # GET /banners.json
    def index
      @banners = Banner.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @banners }
      end
    end
  
    # GET /banners/1
    # GET /banners/1.json
    def show
      @banner = Banner.find_by(:id => params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.js
        format.json { render json: @banner }
      end
    end
  
    # GET /banners/new
    # GET /banners/new.json
    def new
      @banner = Banner.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @banner }
      end
    end
  
    # GET /banners/1/edit
    def edit
      @banner = Banner.find(params[:id])
    end
  
    # POST /banners
    # POST /banners.json
    def create
      @banner = Banner.new(banner_params)
  
      respond_to do |format|
        if @banner.save
          expire_page_cache(@banner)
          format.html { redirect_to banners_path }
          format.json { render json: @banner, status: :created, location: @banner }
        else
          format.html { render action: "new" }
          format.json { render json: @banner.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /banners/1
    # PUT /banners/1.json
    def update
      @banner = Banner.find(params[:id])
  
      respond_to do |format|
        if @banner.update_attributes(banner_params)
          expire_page_cache(@banner)
          format.html { redirect_to banners_path }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @banner.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /banners/1
    # DELETE /banners/1.json
    def destroy
      @banner = Banner.find(params[:id])
      @banner.destroy
  
      respond_to do |format|
        format.html { redirect_to banners_url }
        format.json { head :no_content }
      end
    end

    private


    # Never trust parameters from the scary internet, only allow the white list through.
    def banner_params
      params.fetch(:banner, {}).permit(:name, :tag_line, :img)
    end

  end
end
