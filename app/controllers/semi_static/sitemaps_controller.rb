  require_dependency "semi_static/application_controller"
  
  module SemiStatic
    class SitemapsController < ApplicationController

    helper SemiStatic::EntriesHelper
  
    # Todo: Cache the sitemap until Tag, Entry or Seo is changed
    # caches_page :show, :if => Proc.new { |c| !c.request.format.js? && cachable_content? }
  
    require 'semi_static/general'
    include General
  
    # GET /sitemaps
    #
    # This is a public action to generate the entire sitemap
    #
    def index
      @sitemap = Tag.sitemap(extract_locale_from_tld)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @sitemap }
      end
    end
  
    private

    def cachable_content?
      !request.format.js? && !@tag.subscriber_content && 
        !@tag.admin_only && !(@tag.context_url && params[:no_context]) &&
        !@tag.paginate?
    end

  end
end
