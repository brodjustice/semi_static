require_dependency "semi_static/application_controller"

module SemiStatic
  class FcolsController < ApplicationController

    before_filter :authenticate_user!, :except => :show
  
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
      @fcol = Fcol.new(params[:fcol])
  
      respond_to do |format|
        if @fcol.save
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
        if @fcol.update_attributes(params[:fcol])
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
  end
end
