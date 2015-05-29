  require_dependency "semi_static/application_controller"

  module SemiStatic
    class DocumentsController < ApplicationController

    caches_page :index

    layout 'semi_static_application'

    def index
      @tag = params[:tag_id].present? ? Tag.find(params[:tag_id]) : Tag.predefined(I18n.locale, 'Documents').first
      @entries = Entry.for_documents_tag
      respond_to do |format|
        format.html { render :template => '/semi_static/entries/documents'}
        format.js
      end
    end
  end
end
