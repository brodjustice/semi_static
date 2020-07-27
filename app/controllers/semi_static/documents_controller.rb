  require_dependency "semi_static/application_controller"

  module SemiStatic
    class DocumentsController < ApplicationController

    include SemiStatic::Concerns::DocumentConcern

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
      if params[:squeeze_id].present? && params[:squeeze_id] != 'restricted'
        #
        # This is a standard document that is downloaded by a contact with
        # a key provided by a squeeze
        #
        squeeze = Squeeze.find(params[:squeeze_id])
        contact = Contact.find_by_token(params[:token])
        SemiStatic::ContactMailer.contact_notification(contact).deliver
        send_file squeeze.doc(:url), :type => squeeze.doc_content_type, :disposition => 'inline'
      elsif params[:squeeze_id].present? && params[:squeeze_id] == 'restricted' && SemiStatic::Engine.config.subscribers_model.present?
        #
        # /documents/restricted/:squeeze_id
        #
        # This is a restricted document set up as a squeeze but being downloaded
        # directly. The param[:token] will be the squeeze_id. So we check with the
        # applications subscriber model for the authorization.
        #
        session[:user_intended_url] = url_for(params) unless send('current_' + SemiStatic::Engine.config.subscribers_model.first[0].downcase).present?
        if send('current_' + SemiStatic::Engine.config.subscribers_model.first[0].downcase)
          squeeze = Squeeze.find(params[:token])
          send_file squeeze.doc(:url), :filename => squeeze.doc.original_filename, :type => squeeze.doc_content_type, :disposition => 'inline'
        else
          raise ActiveRecord::RecordNotFound, "Page not found."
        end
      end
    end
  end
end
