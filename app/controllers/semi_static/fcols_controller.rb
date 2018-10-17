require_dependency "semi_static/application_controller"

module SemiStatic
  class FcolsController < ApplicationController

    require 'semi_static/general'
    include General

    before_action :authenticate_for_semi_static!, :except => :show
  
    layout 'semi_static_dashboards'
  
    # GET /fcols
    # GET /fcols.json
    def index
      @fcols = Fcol.order(:position)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @fcols }
      end
    end
  
    # GET /fcols/new
    # GET /fcols/new.json
    def new
      @fcol = Fcol.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @fcol }
      end
    end
  
    # GET /fcols/1/edit
    def edit
      @fcol = Fcol.find(params[:id])
    end
  
    # POST /fcols
    # POST /fcols.json
    def create
      @fcol = Fcol.new(fcol_params)
  
      respond_to do |format|
        if @fcol.save
          expire_page_cache(@fcol)
          format.html { redirect_to fcols_path, notice: 'Footer tag was successfully created.' }
          format.json { render json: @fcol, status: :created, location: @fcol }
        else
          format.html { render action: "new" }
          format.json { render json: @fcol.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /fcols/1
    # PUT /fcols/1.json
    def update
      @fcol = Fcol.find(params[:id])
  
      respond_to do |format|
        if @fcol.update_attributes(fcol_params)
          expire_page_cache(@fcol)
          format.html { redirect_to fcols_path, notice: 'Footer tag was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @fcol.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /fcols/1
    # DELETE /fcols/1.json
    def destroy
      @fcol = Fcol.find(params[:id])
      @fcol.destroy
  
      respond_to do |format|
        format.html { redirect_to fcols_url }
        format.json { head :no_content }
      end
    end

    private


    # Never trust parameters from the scary internet, only allow the white list through.
    def fcol_params
      params.fetch(:fcol, {}).permit(:name, :position, :content, :locale)
    end
  end
end
