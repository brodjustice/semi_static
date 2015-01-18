require_dependency "semi_static/application_controller"

module SemiStatic
  class NewslettersController < ApplicationController
    layout 'semi_static_dashboards'

    before_filter :authenticate_for_semi_static!

    # GET /newsletters
    # GET /newsletters.json
    def index
      @newsletters = Newsletter.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @newsletters }
      end
    end
  
    # GET /newsletters/1
    # GET /newsletters/1.json
    def show
      @newsletter = Newsletter.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @newsletter }
      end
    end
  
    # GET /newsletters/new
    # GET /newsletters/new.json
    def new
      @newsletter = Newsletter.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @newsletter }
      end
    end
  
    # GET /newsletters/1/edit
    def edit
      @newsletter = Newsletter.find(params[:id])
    end
  
    # POST /newsletters
    # POST /newsletters.json
    def create
      @newsletter = Newsletter.new(params[:newsletter])
  
      respond_to do |format|
        if @newsletter.save
          format.html { render action: 'edit', notice: 'Newsletter was successfully created.' }
          format.json { render json: @newsletter, status: :created, location: @newsletter }
        else
          format.html { render action: "new" }
          format.json { render json: @newsletter.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /newsletters/1
    # PUT /newsletters/1.json
    def update
      @newsletter = Newsletter.find(params[:id])
      @newsletter.add_entry(params[:entry])
  
      respond_to do |format|
        if @newsletter.update_attributes(params[:newsletter])
          if params[:publish].present?
            @newsletter.publish
          elsif params[:email_draft].present?
            NewsletterMailer.draft(current_admin, @newsletter).deliver && @newsletter.draft_sent
            format.html { redirect_to newsletters_path, notice:  "Draft of Newsletter #{@newsletter.name} was sent to #{current_admin.email}" }
          else
            format.html { redirect_to newsletter_path(@newsletter), notice: 'Newsletter was updated.' }
            format.json { head :no_content }
          end
        else
          format.html { render action: "edit" }
          format.json { render json: @newsletter.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /newsletters/1
    # DELETE /newsletters/1.json
    def destroy
      @newsletter = Newsletter.find(params[:id])
      @newsletter.destroy
  
      respond_to do |format|
        format.html { redirect_to newsletters_url }
        format.json { head :no_content }
      end
    end
  end
end
