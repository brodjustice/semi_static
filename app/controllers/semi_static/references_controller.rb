require_dependency "semi_static/application_controller"

module SemiStatic
  class ReferencesController < ApplicationController
    before_filter :authenticate_user!, :class => SemiStatic::Reference, :only => [ :create, :update, :destroy ]
  
    caches_page :show

    layout 'semi_static_dashboards'
  
    # GET /references
    # GET /references.json
    def index
      @references = Reference.all
      @reference = @references.first
      @selection = 'References'
      @tag, @seo = Seo.references(params[:tag_id], I18n.locale)
  
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
      @title = @reference.title
  
      respond_to do |format|
        format.html { render :layout => 'semi_static_application' }
        format.json { render json: @reference }
      end
    end
  
    # GET /references/new
    # GET /references/new.json
    def new
      if params[:master].present?
        master = Reference.find(params[:master])
        @reference = master.dup
      else
        @reference = Reference.new
      end

  
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
          format.html { redirect_to references_path }
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
          format.html { redirect_to references_path }
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
