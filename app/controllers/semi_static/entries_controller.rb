  require_dependency "semi_static/application_controller"
  
  module SemiStatic
    class EntriesController < ApplicationController

    require 'semi_static/general'
    include General
  
    before_action :authenticate_for_semi_static!,  :except => [ :show, :search ]
  
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
      elsif params[:nopaginate]
        @entries = Entry.unscoped.order(:locale, :tag_id, :position).exclude_newsletters
        @nopaginate = true
      else
        @entries = Entry.unscoped.order(:locale, :tag_id, :position).exclude_newsletters.page(params[:page])
      end
      respond_to do |format|
        format.html { render :template => template, :layout => layout }
        format.js
      end
    end
  
    # GET /articles/search
    def search
      if params[:q].present? || params[:query].present?
        @entries_with_hit = Entry.search(params[:q] || params[:query], session[:locale]).records
        @entries = @entries_with_hit.select{|e| e.indexable}.collect{|e| e.merged_main_entry}.uniq
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

      #
      # We restrict the Entry to those with the correct locale. In the past we did not check the locale but
      # it can cause problems were search engines look up an Entry with a locale that does not match the website
      # and then index it, the result would be for example 'de' local pages being indexed on the 'en' website.
      #
      @entry = Entry.where(:locale => locale.to_s).find(params[:id])
      @tag = @entry.tag


      #
      # Is this an Entry request that actually just wants a popup of the Entry image?
      #
      if params[:popup].present?
        @pixel_ratio = params[:pratio].to_i || 1
        @popup_style = popup_style(@entry, @pixel_ratio)
        @caption = @entry.image_caption
        template = "semi_static/photos/popup"
      else
        #
        # Check if this is an entry that needs a redirect. This sort of functionality is replicated in the site_helper
        # but with slight differences that make it tricky to combine.
        #
        redirect_path = @entry.link_to_tag && feature_path(@entry.tag.slug) ||
          @entry.merge_with_previous && semi_static.entry_path(@entry.merged_main_entry) ||
          @entry.acts_as_tag_id && feature_path(@entry.acts_as_tag.slug) ||
          request.path.start_with?('/entries') && @entry.tag.context_url && "/#{@entry.tag.name.parameterize}/#{@entry.to_param}"
      end

      if redirect_path.blank? && params[:popup].blank?
        # Is this a canonical Entry URL, perhaps with context URL path part
        context_url_or_entry = @entry.tag.context_url.present? ? @entry.tag.title.parameterize : 'entries'
        @entry.canonical(@entry.tag.context_url.present?) && (@canonical = request.protocol + request.host + "/#{context_url_or_entry}/" + @entry.to_param)

        # Check if this should only be seen by the admin.
        @entry.admin_only && authenticate_for_semi_static!

        @title = ActionController::Base.helpers.strip_tags(@entry.title)
        @seo = @entry.seo
        @side_bar = @entry.side_bar
        @banner_class = @entry.banner && 'bannered'
        # If we call this via a URL and this is a merged entry, then we
        # need to only show this entry, not additional merged entries
        @suppress_merged = @entry.merge_with_previous

        if @entry.enable_comments
          @comment = @entry.comments.new
        end

        # Work out the Tag to use for the sidebar menu. Check special PageAttrs for sideBarMenuTagId
        # and sideBarMenuTagIds
        @sidebar_menu_tag = @entry.get_page_attr('sideBarMenuTagId')&.split ||
          @entry.get_page_attr('sideBarMenuTagIds')&.split(",") ||
          @entry.tag

        # Work out what image (if any) "style" should be applied. Check if PageAttr imageStyle provided
        @entry_image_style = @entry.get_page_attr('imageStyle')&.to_sym || (@entry.side_bar ? :show : :medium)

        # Check if this is subscriber only content.

        # Here you must have Devise gem for authentication, or some other method that authorises 'current_user'
        if @entry.subscriber_content && !(semi_static_admin? || send('current_' + SemiStatic::Engine.config.subscribers_model.first[0].downcase))

          # Save this URL for after the subscriber has signed in
          session[:user_intended_url] = url_for(params.permit)

          #
          # Show only a summary of the Entry and render template that includes a sign-in dialog
          #
          @summaries = true
          template = 'semi_static/entries/subscriber_entry'

          #
          # If you want to totally protect your subscriber content, rather than showing a teaser summary then
          # you will need to redirect to the signin page like this:
          #     send('authenticate_' + SemiStatic::Engine.config.subscribers_model.first[0].downcase + '!')

        end
      end


      respond_to do |format|
        format.html {
          if redirect_path
            redirect_to redirect_path
          else
            # Everthing ok, show content or summary content
            render :template => template || 'semi_static/entries/show', :layout => 'semi_static_application'
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
        @entry = nl.tag.entries.build(entry_params)
        @entry.save
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
            format.html { redirect_to entries_path(:anchor => "entry_id_#{@entry.id}", :page => page(@entry)) }
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

      #
      # Redirects only apply to html format calls
      #
      redirect_path = params[:redirect_to] ||
        (@entry.tag.newsletter && edit_newsletter_path(@entry.tag.newsletter)) ||
        entries_path(:anchor => "entry_id_#{@entry.id}", :page => "#{page(@entry)}")

      if params[:convert] && (@entry.attributes = entry_params)
        template = 'convert'
      else
        template = 'update'
        @entry.update_attributes(entry_params) && expire_page_cache(@entry)
        
      end

      @entry.notice.present? && (flash[:notice] = @entry.notice)
      
      respond_to do |format|
        if @entry.errors.none?
          format.html { redirect_to redirect_path }
          format.js { render template }
        else
          format.html { render :action => "edit" }
        end
      end
    end
  
    # DELETE /entries/1
    # DELETE /entries/1.json
    def destroy
      @entry = Entry.find(params[:id])
      expire_page_cache(@entry)
      @tag = @entry.tag
      @entry.destroy
  
      respond_to do |format|
        format.html { redirect_to tag_entries_url(@tag) }
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

    # Get the page number that an entry is on when paginating. This could be abstracted as a Class method
    # for other objects like Photos
    #
    def page(entry, per_page = Entry.default_per_page)
      position = Entry.unscoped.order(:locale, :tag_id, :position).exclude_newsletters.pluck(:id).index(entry.id)
      (position.to_f/per_page).ceil
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def entry_params
      params.fetch(:entry, {}).permit(:title, :sub_title, :body, :tag_id, :home_page, :summary, :img, :news_item, :image_in_news, :image_disable, :news_img, :newsletter_img,
      :position, :doc, :doc_description, :summary_length, :locale, :style_class, :header_colour, :background_colour, :colour,
      :banner_id, :partial, :entry_position, :master_entry_id, :youtube_id_str, :use_as_news_summary, :simple_text,
      :sidebar_id, :side_bar, :side_bar_news, :side_bar_social, :side_bar_search, :side_bar_gallery, :side_bar_tag_id, :unrestricted_html,
      :merge_with_previous, :raw_html, :image_popup, :alt_title, :acts_as_tag_id, :gallery_id,
      :facebook_share, :linkedin_share, :xing_share, :twitter_share, :email_share, :instagram_share, :show_in_documents_tag, :image_caption,
      :tag_line, :raw_html, :show_image_titles, :doc_delete, :img_delete, :alt_img_delete,
      :enable_comments, :comment_strategy, :layout_select, :link_to_tag, :style, :event_id, :squeeze_id, :job_posting_id)
    end


    def cachable_content?
      !request.format.js? &&
        @entry.canonical &&
        !@entry.subscriber_content &&
        !@entry.admin_only &&
        !(@entry.tag.context_url && params[:no_context])
    end
  end
end
