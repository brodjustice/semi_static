  require_dependency "semi_static/application_controller"
  
  module SemiStatic
    class TagsController < ApplicationController
  
    before_filter :authenticate_for_semi_static!, :except => :show
    before_filter :authenticate_semi_static_subscriber!,  :only => [ :show ]

    caches_page :show, :if => Proc.new { |c| !c.request.format.js? && cachable_content? }
  
    layout 'semi_static_dashboards'

    require 'semi_static/general'
    include General
  
    # GET /tags
    # GET /tags.json
    def index
      @tags = Tag.unscoped.order(:locale, :position).where(:newsletter_id => nil)
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @tags }
      end
    end
  
    # GET /tags/1
    # GET /tags/1.json
    def show
      @title = @tag.name
      @seo = @tag.seo
      @banner_class = @tag.banner && 'bannered'

      # If only one entry and it has link_to_tag set then that is the full content to this page
      @tag.entries.size == 1 && @tag.entries.first.link_to_tag && ((@entry = @tag.entries.first) && (@link_to_tag = true))

      # The entries are not linked if we have link to tag set
      @link_to_tag ? (@linked = false) : (@summaries = true)
      @side_bar = @tag.side_bar
      !@side_bar && (@group_size = 3)

      @tag.admin_only && authenticate_for_semi_static!
  
      respond_to do |format|
        format.html {
          if @tag.predefined_class && !SiteHelper::PREDEFINED[@tag.predefined_class].nil?
            redirect_to SiteHelper::PREDEFINED[@tag.predefined_class]
          else
            render :layout => layout_select(@tag)
          end
        }
      end
    end
  
    # GET /tags/new
    # GET /tags/new.json
    def new
      @tag = Tag.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @tag }
      end
    end
  
    # GET /tags/1/edit
    def edit
      @tag = Tag.find(params[:id])
    end
  
    # POST /tags
    # POST /tags.json
    def create
      @tag = Tag.new(params[:tag])
  
      respond_to do |format|
        if @tag.save
          format.html { redirect_to tags_path(:anchor => "tag_id_#{@tag.id}"), :notice => 'Tag was successfully created.' }
          format.json { render :json => @tag, :status => :created, :location => @tag }
        else
          format.html { render :action => "new" }
          format.json { render :json => @tag.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # PUT /tags/1
    # PUT /tags/1.json
    def update
      @tag = Tag.find(params[:id])
  
      respond_to do |format|
        if @tag.update_attributes(params[:tag])
          format.html { redirect_to tags_path(:anchor => "tag_id_#{@tag.id}"), :notice => 'Tag was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render :action => "edit" }
          format.json { render :json => @tag.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # DELETE /tags/1
    # DELETE /tags/1.json
    def destroy
      @tag = Tag.find(params[:id])
      @tag.destroy
  
      respond_to do |format|
        format.html { redirect_to tags_url }
        format.json { head :no_content }
      end
    end

    private

    def cachable_content?
      # !lambda{ |controller| controller.request.format.js? } && !@entry.subscriber_content
      !request.format.js? && !@tag.subscriber_content && !@tag.admin_only && !(@tag.context_url && params[:no_context])
    end

    def authenticate_semi_static_subscriber!
      # You might want to look for slugs of different locales, especially if these are custom
      # pages. So first look for tag in current locale and if this fails take first matching tag
      @tag = Tag.where(:locale => locale.to_s).find_by_slug(params[:slug]) || Tag.find_by_slug!(params[:slug])
      if !semi_static_admin? && @tag.subscriber_content
        session[:user_intended_url] = url_for(params) unless send('current_' + SemiStatic::Engine.config.subscribers_model.first[0].downcase)
        send('authenticate_' + SemiStatic::Engine.config.subscribers_model.first[0].downcase + '!')
      end
    end
  end
end
