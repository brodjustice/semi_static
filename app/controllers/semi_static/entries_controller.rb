  require_dependency "semi_static/application_controller"
  
  module SemiStatic
    class EntriesController < ApplicationController

    require 'semi_static/general'
    include General
  
    before_action :authenticate_for_semi_static!,  :except => [ :show, :search ]
    before_action :authenticate_semi_static_subscriber!,  :only => [ :show ]
  
    # We would like to do something like this:
    #   caches_page :show, :if => :not_subscriber_content?
    # but Rails 3.x will not take the :if. So we have to rewrite the
    # page cache to a after_filter like this
    #   after_filter(:only => :show) { |c| c.cache_page if cachable_content?}
    # But then we also don't cache subsriber content or ajax requests (to the entry image):
    caches_page :show, :if => Proc.new { |c| !c.request.format.js? && cachable_content? }
  
    layout 'semi_static_dashboards'
  
    # GET /entries
    # GET /entries.json
    def index
      template = '/semi_static/entries/index'; layout = 'semi_static_dashboards';

      if params[:tag_id].present? || session[:workspace_tag_id]
        @tag = Tag.find(params[:tag_id] || session[:workspace_tag_id])
        @entries = @tag.entries
      else
        @entries = Entry.unscoped.order(:locale, :tag_id, :position).exclude_newsletters
        @newsletter_entries = Entry.unscoped.for_newsletters
      end
      respond_to do |format|
        format.html { render :template => template, :layout => layout }
        format.json { render :json => @entries }
        format.js
      end
    end
  
    # GET /articles/search
    def search
      if params[:q].present? || params[:query].present?
        @entries_with_hit = Entry.search(params[:q] || params[:query], session[:locale]).records
        @entries = @entries_with_hit.select{|e| e.indexable}.collect{|e| e.merged_main_entry}
        @hit_count = @entries.count
        @query = params[:q]
        template = 'semi_static/entries/results'
      else
        template = 'semi_static/entries/search'
      end
  
      render template: template, layout: 'semi_static_application'
    end
  
  
    # GET /entries/1
    # GET /entries/1.json
    def show
      unless params[:popup].present?
        @title = ActionController::Base.helpers.strip_tags(@entry.title)
        @seo = @entry.seo
        @side_bar = @entry.side_bar
        @banner_class = @entry.banner && 'bannered'
        # If we call this via a URL and this is a merged entry, then we
        # need to only show this entry, not additional merged entries
        @suppress_merged = @entry.merge_with_previous
        # Don't have a header link to yourself
        @linked = false
      else
        @pixel_ratio = params[:pratio].to_i || 1
        @popup_style = popup_style(@entry, @pixel_ratio)
        @caption = @entry.image_caption
        template = "semi_static/photos/popup"
      end

      if @entry.enable_comments
        @comment = @entry.comments.new
      end

      # Check if this should only be seen by the admin. Careful to not here that other
      # security, eg for subscriber only content is done in the views. This is hardly
      # ideal but give the cache strategy it is the most efficient manner.
      @entry.admin_only && authenticate_for_semi_static!

      # Work out the Tag to use for the sidebar menu
      @sidebar_menu_tag = (@entry.get_page_attr('sideBarMenuTagId') ? Tag.find(@entry.get_page_attr('sideBarMenuTagId')) : @entry.tag)


      respond_to do |format|
        format.html {
          if @entry.tag.context_url && params[:no_context]
            # Redirect if the tag has a context_url
            redirect_to "/#{@entry.tag.name.parameterize}/#{params[:id]}"
          elsif @entry.merge_with_previous
            # Redirect merged entries to the main entry
            redirect_to entry_path(@entry.merged_main_entry)
          elsif @entry.link_to_tag
            # Redirect link_to_tag entries to their tag
            redirect_to feature_path(@entry.tag.slug)
          # End of redirects, only option left is to go to the view template
          elsif  @entry.subscriber_content && current_user.nil?
            # This is subscriber content so just show a teaser
            @summaries = true
            render :template => 'semi_static/entries/subscriber_entry', :layout => 'semi_static_application'
          else
            # Everthing ok and no restrictions, show the content
            render :layout => 'semi_static_application'
          end
        }
        format.js { render :template => template }
      end
    end
  
    # GET /entries/new
    # GET /entries/new.json
    def new
      @entry = Entry.new(:simple_text => true, :body => '', :locale => params[:locale], :tag_id => params[:tag_id] || session[:workspace_tag_id])
      if params[:master].present?
        master = Entry.find(params[:master])
        @entry = master.tidy_dup
        @entry.master_entry = master
      elsif params[:merge]
        @entry.merge_with(Entry.find(params[:merge]))
      elsif params[:newsletter]
        @newsletter = Newsletter.find(params[:newsletter])
        @entry.tag = @newsletter.tag
      end
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @entry }
      end
    end
  
    # GET /entries/1/edit
    def edit
      @entry = Entry.find(params[:id])
      template = params[:mode] == 'html' ? 'semi_static/entries/edit_html' : 'semi_static/entries/edit'
      respond_to do |format|
        format.html { render :template => template }
        format.js { render :template => template }
        format.json { render :json => @entry }
      end
    end
  
    # POST /entries
    # POST /entries.json
    def create
      if params[:newsletter_id]
        nl = SemiStatic::Newsletter.find(params[:newsletter_id])
        @entry = nl.tag.entries.create(entry_params)
        nl.add_entry(@entry, true)
      else
        @entry = Entry.new(entry_params)
      end
      respond_to do |format|
        if params[:preview]
          format.js { render 'preview'}
        elsif params[:convert]
          format.js { render 'convert'}
        elsif @entry.save
          expire_page_cache(@entry)
          if params[:newsletter_id]
            format.html { redirect_to edit_newsletter_path(params[:newsletter_id]) }
          else
            format.html { redirect_to entries_path(:anchor => "entry_id_#{@entry.id}") }
            format.json { render :json => @entry, :status => :created, :location => @entry }
          end
        else
          format.html { render :action => "new" }
          format.json { render :json => @entry.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # PUT /entries/1
    # PUT /entries/1.json
    def update
      @entry = Entry.find(params[:id])
      respond_to do |format|
        if params[:preview] && (@entry.attributes = params[:entry])
          format.js { render 'preview'}
        elsif params[:convert] && (@entry.attributes = params[:entry])
          format.js { render 'convert'}
        elsif @entry.update_attributes(entry_params)
          unless @entry.notice.blank?
            flash[:notice] = @entry.notice
          end
          expire_page_cache(@entry)
          format.html {
            if params[:redirect_to].present?
              redirect_to params[:redirect_to]
            else
              redirect_to entries_path(:anchor => "entry_id_#{@entry.id}")
            end
          }
          format.js
        else
          format.html { render :action => "edit" }
          format.js
          format.json { render :json => @entry.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # DELETE /entries/1
    # DELETE /entries/1.json
    def destroy
      @entry = Entry.find(params[:id])
      expire_page_cache(@entry)
      @entry.destroy
  
      respond_to do |format|
        format.html { redirect_to entries_url }
        format.json { head :no_content }
      end
    end

    protected

    # Derives the inline type for double density popup image based on Photo(p) and pixel ratio (pr)
    # The wierd thing is that the double density image is massively compressed, and is so not as
    # not as many Mbytes as half width (1/4 of the area) version. However, because of the extra pixel
    # density the image still renders better than the single density half width, 1/4 size, version
    #
    # TODO: This is also used in photos_controller, refactor into lib
    def popup_style(e, pr)
      unless e.img_dimensions.blank?
        pr = pr.round
        @width = e.img_dimensions.first.to_i/2
        @height = e.img_dimensions.last.to_i/2
        url = ((pr > 1.5) ? e.img.url(:compressed) : e.img.url(:half))
        "background-image: url(#{url}); background-size: #{@width}px #{@height}px; width:#{@width}px; height:#{@height}px;"
      else
        "background: url(#{e.img.url}) center center no-repeat; background-size: cover;"
      end
    end

    private


    # Never trust parameters from the scary internet, only allow the white list through.
    def entry_params
      params.fetch(:entry, {}).permit(:title, :sub_title, :body, :tag_id, :home_page, :summary, :img, :news_item, :image_in_news, :image_disable, :news_img, :newsletter_img,
      :position, :doc, :doc_description, :summary_length, :locale, :style_class, :header_colour, :background_colour, :colour,
      :banner_id, :partial, :entry_position, :master_entry_id, :youtube_id_str, :use_as_news_summary, :simple_text,
      :sidebar_id, :side_bar, :side_bar_news, :side_bar_social, :side_bar_search, :side_bar_gallery, :side_bar_tag_id, :unrestricted_html,
      :merge_with_previous, :raw_html, :image_popup, :alt_title, :acts_as_tag_id, :gallery_id,
      :facebook_share, :linkedin_share, :xing_share, :twitter_share, :email_share, :show_in_documents_tag, :image_caption,
      :tag_line, :raw_html, :show_image_titles, :doc_delete, :img_delete, :alt_img_delete,
      :enable_comments, :comment_strategy, :layout_select, :link_to_tag, :style, :event_id, :squeeze_id, :job_posting_id)
    end


    def cachable_content?
      # !lambda{ |controller| controller.request.format.js? } && !@entry.subscriber_content
      !request.format.js? && !@entry.subscriber_content && !@entry.admin_only && !(@entry.tag.context_url && params[:no_context])
    end

    #
    # The Entry itself is retrieved here. We restrict the Entry to those with the correct locale. In the past
    # we did not check the locale this but it can cause problems were search engines look up an Entry with a locale that does
    # not match the website and then index it.
    #
    def authenticate_semi_static_subscriber!
      @entry = Entry.where(:locale => locale.to_s).find(params[:id])
      @tag = @entry.tag

      if !semi_static_admin? && @entry.subscriber_content
        session[:user_intended_url] = url_for(params.permit) unless send('current_' + SemiStatic::Engine.config.subscribers_model.first[0].downcase)
        # If you want to totally protect your subscriber content, rather than showing a teaser summary then
        # you will need to redirect to the signin page like this:
        #
        #     send('authenticate_' + SemiStatic::Engine.config.subscribers_model.first[0].downcase + '!')
      end
    end

  end
end
