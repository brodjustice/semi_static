  require_dependency "semi_static/application_controller"
  
  module SemiStatic
    class TagsController < ApplicationController

    helper SemiStatic::EntriesHelper
  
    before_action :authenticate_for_semi_static!, :except => :show
    before_action :authenticate_semi_static_subscriber!,  :only => [ :show ]

    caches_page :show, :if => Proc.new { |c| !c.request.format.js? && cachable_content? }
  
    layout 'semi_static_dashboards'

    require 'semi_static/general'
    include General
  
    # GET /tags
    # GET /tags.json
    def index
      @tag_sets = {
        :public => Tag.unscoped.order(:locale, :position).where(:newsletter_id => nil).where(:admin_only => false),
        :admin_only => Tag.unscoped.order(:locale, :position).where(:newsletter_id => nil).where(:admin_only => true)
      }
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @tags_sets }
      end
    end
  
    # GET /tags/1
    # GET /tags/1.json
    def show
      @tag.admin_only && authenticate_for_semi_static!

      #
      # The config/routes.rb will direct Tag index pages to this controller even if the Tag locale
      # does not match the domain locale, so raise an error for those pages:
      #
      if @tag.locale != extract_locale_from_tld
        raise ActionController::RoutingError, "Not found on this domain"
      end

      #
      # When the Tag has #use_entry_as_tag_index we are saying take the contents of that Entry
      # and display it in the Tag page. We used to simply cause a redirect for this, eg:
      #   redirect_to entry_path(@tag.use_entry_as_index)
      # but it's not really correct because we want to keep the URL for the Tag and replace
      # entire Tag view contents. So instead we now call the Entries controller to create
      # our html for the page
      #
      if @tag.use_entry_as_index
        entries_controller = SemiStatic::EntriesController.new
        entries_controller.request = request
        entries_controller.response = response
        entries_controller.params[:id] = @tag.use_entry_as_index.id
        html_content = entries_controller.show 
      end

      #
      # Predefined tags are a redirect or we already have the html_content if
      # use_entry_as index was set, so in either case we don't need the block
      # below to set up the content for the Tag page
      #
      unless @tag.predefined_class.present? || @tag.use_entry_as_index

        @title = @tag.name
        @seo = @tag.seo
        @banner_class = @tag.banner && 'bannered'

        # If only one entry and it has link_to_tag set then that is the full content to this page
        @tag.entries.unmerged.size <= 1 && @tag.entries.unmerged.first.try('link_to_tag') &&
          ((@entry = @tag.entries.unmerged.first) && (@link_to_tag = true))

        # The entries are not linked if we have link to tag set
        @link_to_tag ? (@linked = false) : (@summaries = true)
        @side_bar = @tag.side_bar
        !@side_bar && (@group_size = 3)

        # Work out the Tag to use for the sidebar menu. Check special PageAttrs for sideBarMenuTagId
        # and sideBarMenuTagIds
        @sidebar_menu_tag = @tag.get_page_attr('sideBarMenuTagId')&.split ||
          @tag.get_page_attr('sideBarMenuTagIds')&.split(",")

        # Work out what image (if any) "style" should be applied. Check if PageAttr imageStyle provided
        @entry_image_style = @tag.get_page_attr('imageStyle')&.to_sym || :summary

        # Make headers link to the main entry
        @linked = true

        # Do we need to paginate the entries?
        if @tag.paginate?
          @tag.max_entries_on_index_page = params[:per].to_i || @tag.paginate_at
          @entries_for_pagination = @tag.entries.unmerged.page(params[:page]).per(params[:per] || @tag.paginate_at)
        end

      end

      # If the Tag for sidebar menu has not yet been set, then default to the current Tag
      @sidebar_menu_tag ||= @tag

      respond_to do |format|
        format.html {
          if html_content
            render :html => html_content.html_safe
          elsif @tag.predefined_class.present? && view_context.predefined_route(@tag.predefined_class).present?
            redirect_to view_context.predefined_route(@tag.predefined_class)
          else
            render :layout => SemiStatic::Engine.layout_select(@tag)
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
      @tag = Tag.new(tag_params)
  
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
        if @tag.update_attributes(tag_params)
          expire_page_cache(@tag)
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
      expire_page_cache(@tag)
      @tag.destroy
  
      respond_to do |format|
        format.html { redirect_to tags_url }
        format.json { head :no_content }
      end
    end

    private

    # 
    # The .merge(:href_lang_tag_ids => [params[:href_lang_tag]]) is for the form dialog in views/hreflangs which
    # adds ony one more tag (normally no hidden attrs).
    #
    def tag_params
      params.fetch(:tag, {}).permit(:name, :menu, :position, :icon, :icon_in_menu, :icon_delete, :sidebar_title,
        :predefined_class, :colour, :icon_resize, :locale, :max_entries_on_index_page,
        :banner_id, :partial, :entry_position, :tag_line, :subscriber, :sidebar_id,
        :side_bar, :side_bar_news, :side_bar_social, :side_bar_search, :side_bar_tag_id, :layout_select,
        :target_tag_id, :target_name, :context_url, :admin_only, :use_entry_as_index_id, :href_equiv_tag_ids => [])
        .merge(
          if params[:href_lang_tag]
            {:href_equiv_tag_ids => [params[:href_lang_tag]] + @tag.href_equiv_tag_ids}
          else
            {:href_equiv_tag_ids => params[:href_equiv_tag_ids]}
          end
        )
    end

    def cachable_content?
      !request.format.js? && !@tag.subscriber_content && 
        !@tag.admin_only && !(@tag.context_url && params[:no_context]) &&
        !@tag.paginate?
    end

    def authenticate_semi_static_subscriber!
      # You might want to look for slugs of different locales, especially if these are custom
      # pages. So first look for tag in current locale and if this fails take first matching tag
      @tag = Tag.where(:locale => locale.to_s).find_by_slug(params[:slug]) || Tag.find_by_slug!(params[:slug])
      if !semi_static_admin? && @tag.subscriber_content
        session[:user_intended_url] = url_for(params.permit) unless send('current_' + SemiStatic::Engine.config.subscribers_model.first[0].downcase)
        # If you want to totally protect your subscriber content, rather than showing a teaser summary then
        # you will need to redirect to the signin page like this:
        #
        # send('authenticate_' + SemiStatic::Engine.config.subscribers_model.first[0].downcase + '!')
        #
        # See also the entries_controller.rb
        #
      end
    end
  end
end
