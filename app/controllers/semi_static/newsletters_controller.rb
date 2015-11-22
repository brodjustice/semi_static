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
      template = 'edit'

      # TODO: Big refactor required here
      if params[:position]
        @newsletter.order_entries_to_position 
      elsif params[:select_entry]
        template = 'select_entry'
        @entry = Entry.find_by_id(params[:select_entry])
        @entries = Entry.unscoped.order(:locale, :tag_id, :position)
      elsif params[:select_layout]
        @entry = Entry.find_by_id(params[:select_layout])
        template = 'select_layout'
      elsif params[:remove]
        @newsletter.remove_entry_id(params[:remove])
      elsif params[:css]
        template = 'css'
      elsif params[:max_image_attachments]
        template = 'max_image_attachments'
      elsif params[:sender_address]
        template = 'sender_address'
      elsif params[:newsletter_img]
        template = 'newsletter_img'
        @entry = Entry.find_by_id(params[:newsletter_img])
      elsif params[:newsletter_img_updated]
        @newsletter.use_newsletter_img(params[:newsletter_img_updated])
      elsif params[:salutation]
        template = 'salutation'
      elsif params[:swap_image]
        template = @newsletter.swap_entry_image(params[:swap_image].to_i).nil? ? 'select_image' : 'swap_image'
        @entry = Entry.find_by_id(params[:swap_image])
      elsif params[:header]
        template = 'header'
      end

      respond_to do |format|
        format.html { render :template => "semi_static/newsletters/#{template}" }
        format.js { render :template => "semi_static/newsletters/#{template}" }
      end
    end
  
    # POST /newsletters
    # POST /newsletters.json
    def create
      @newsletter = Newsletter.new(params[:newsletter])
      unless params[:tag].blank?
        Tag.find(params[:tag]).entries.unmerged.collect{|e| @newsletter.draft_entry_ids[e.id] = {}} 
      end
  
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
      @newsletter.add_entry(params[:entry]) unless params[:set_layout].present?

      respond_to do |format|
        if @newsletter.update_attributes(params[:newsletter])
          if params[:publish].present?
            @newsletter.publish(params[:subscriber].keys)
            @newsletter.published
            @delivery = @newsletter.newsletter_deliveries.pending.first
            format.html { render action: "sending" }
          elsif params[:set_layout]
            @newsletter.set_layout(params[:entry][:id], params[:entry][:layout])
            format.html { render action: "edit" }
          elsif params[:insert_newsletter_img].present?
            @entry = Entry.find_by_id(params[:entry_id])
          elsif params[:prepare].present?
            @subscribers = Subscriber.where('locale = ?', @newsletter.locale)
            format.html { render action: "prepare" }
          elsif params[:email_draft].present?
            NewsletterMailer.draft(semi_static_admin?, @newsletter).deliver && @newsletter.draft_sent
            format.html { redirect_to newsletters_path, notice:  "Draft of Newsletter #{@newsletter.name} was sent to #{semi_static_admin?.email}" }
          else
            format.html { render action: 'edit', notice: 'Newsletter was updated.' }
            format.js { render :template => 'semi_static/newsletters/close_dialog' }
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
