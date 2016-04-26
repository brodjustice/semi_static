require_dependency "semi_static/application_controller"

module SemiStatic
  class SqueezesController < ApplicationController
 
    before_filter :authenticate_for_semi_static!, :except => :show

    layout 'semi_static_dashboards'

    def index
      @squeezes = Squeeze.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @squeezes }
      end
    end
  
    def show
      @squeeze = Squeeze.find(params[:id])
      @contact = Contact.new(:strategy => Contact::STRATEGIES[:download], :reason => @squeeze.name.to_s, :squeeze_id => @squeeze.id)
  
      respond_to do |format|
        format.html # show.html.erb
        format.js
      end
    end
  
    def new
      @squeeze = Squeeze.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @squeeze }
      end
    end
  
    def edit
      @squeeze = Squeeze.find(params[:id])
    end
  
    def create
      @squeeze = Squeeze.new(params[:squeeze])
  
      respond_to do |format|
        if @squeeze.save
          @squeezes = Squeeze.all
          format.html { redirect_to squeezes_path, notice: 'Squeeze was successfully created.' }
          format.json { render json: @squeeze, status: :created, location: @squeeze }
        else
          format.html { render action: "new" }
          format.json { render json: @squeeze.errors, status: :unprocessable_entity }
        end
      end
    end
  
    def update
      @squeeze = Squeeze.find(params[:id])
  
      respond_to do |format|
        if @squeeze.update_attributes(params[:squeeze])
          @squeezes = Squeeze.all
          format.html { redirect_to squeezes_path, notice: 'Squeeze was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @squeeze.errors, status: :unprocessable_entity }
        end
      end
    end
  
    def destroy
      @squeeze = Squeeze.find(params[:id])
      @squeeze.destroy
  
      respond_to do |format|
        format.html { redirect_to squeezes_url }
        format.json { head :no_content }
      end
    end
  end
end
