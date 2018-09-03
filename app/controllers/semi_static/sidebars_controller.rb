require_dependency "semi_static/application_controller"

module SemiStatic
  class SidebarsController < ApplicationController

    before_action :authenticate_for_semi_static!

    layout 'semi_static_dashboards'

    # GET /sidebars
    # GET /sidebars.json
    def index
      @sidebars = Sidebar.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @sidebars }
      end
    end
  
    # GET /sidebars/new
    # GET /sidebars/new.json
    def new
      @sidebar = Sidebar.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sidebar }
      end
    end
  
    # GET /sidebars/1/edit
    def edit
      @sidebar = Sidebar.find(params[:id])
    end
  
    # POST /sidebars
    # POST /sidebars.json
    def create
      @sidebar = Sidebar.new(sidebar_params)
  
      respond_to do |format|
        if @sidebar.save
          format.html { redirect_to sidebars_path(:anchor => "sidebar_id_#{@sidebar.id}"), notice: 'Sidebar was successfully created.' }
          format.json { render json: @sidebar, status: :created, location: @sidebar }
        else
          format.html { render action: "new" }
          format.json { render json: @sidebar.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /sidebars/1
    # PUT /sidebars/1.json
    def update
      @sidebar = Sidebar.find(params[:id])
  
      respond_to do |format|
        if @sidebar.update_attributes(sidebar_params)
          format.html { redirect_to sidebars_path(:anchor => "sidebar_id_#{@sidebar.id}"), notice: 'Sidebar was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sidebar.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /sidebars/1
    # DELETE /sidebars/1.json
    def destroy
      @sidebar = Sidebar.find(params[:id])
      @sidebar.destroy
  
      respond_to do |format|
        format.html { redirect_to sidebars_url }
        format.json { head :no_content }
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def sidebar_params
      params.fetch(:sidebar, {}).permit(:title, :body, :bg, :color, :bg_color, :style_class, :partial)
    end


  end
end
