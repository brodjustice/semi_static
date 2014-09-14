require_dependency "semi_static/application_controller"

module SemiStatic
  class ReferencesController < ApplicationController
    load_and_authorize_resource :class => SemiStatic::Reference, :except => [:index, :new, :create, :show]
    before_filter :authenticate_user!, :class => SemiStatic::Reference, :only => [ :new ]
  
    caches_page :show

    layout 'semi_static_dashboards'
  
    # GET /references
    # GET /references.json
    def index
      @references = Reference.all
      @reference = @references.first
      @selection = 'References'
  
      layout = (current_user ? 'semi_static_dashboards' : 'semi_static_application')
      template = (current_user ? 'semi_static/references/admin_index' : 'semi_static/references/index')
  
      respond_to do |format|
        format.html { render :template => template, :layout => layout }
        format.json { render json: @references }
      end
    end
  
    # GET /references/1
    # GET /references/1.json
    def show
      @reference = Reference.find(params[:id])
      @selection = 'References'
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @reference }
      end
    end
  
    # GET /references/new
    # GET /references/new.json
    def new
      @reference = Reference.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @reference }
      end
    end
  
    # GET /references/1/edit
    def edit
      @reference = Reference.find(params[:id])
    end
  
    # POST /references
    # POST /references.json
    def create
      @reference = Reference.new(params[:reference])
  
      respond_to do |format|
        if @reference.save
          format.html { redirect_to @reference }
          format.json { render json: @reference, status: :created, location: @reference }
        else
          format.html { render action: "new" }
          format.json { render json: @reference.errors, status: :unprocessable_entity }
        end
      end
    end
    # PUT /references/1
    # PUT /references/1.json
    def update
      @reference = Reference.find(params[:id])
  
      respond_to do |format|
        if @reference.update_attributes(params[:reference])
          format.html { redirect_to @reference }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @reference.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /references/1
    # DELETE /references/1.json
    def destroy
      @reference = Reference.find(params[:id])
      @reference.destroy
  
      respond_to do |format|
        format.html { redirect_to references_url }
        format.json { head :no_content }
      end
    end
  end
end
