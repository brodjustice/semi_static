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

    def show
      squeeze = Squeeze.find(params[:squeeze_id])
      contact = Contact.find_by_token(params[:token])
      SemiStatic::ContactMailer.contact_notification(contact).deliver
      send_file squeeze.doc(:url), :type => squeeze.doc_content_type, :disposition => 'inline'
    end
  end
end
