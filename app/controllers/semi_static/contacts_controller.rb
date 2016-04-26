require_dependency "semi_static/application_controller"

module SemiStatic
  class ContactsController < ApplicationController

    before_filter :authenticate_for_semi_static!, :except => [:new, :create]
    caches_page :new, :if => Proc.new { |c| c.request.params[:registration].blank? }
  
    # GET /contacts
    # GET /contacts.json
    def index
      @contacts = Contact.all
  
      respond_to do |format|
        format.html { render :layout => 'semi_static_dashboards' }
        format.json { render :json => @contacts }
      end
    end
  
    # GET /contacts/1
    # GET /contacts/1.json
    def show
      @contact = Contact.find(params[:id])
  
      respond_to do |format|
        format.html { render :layout => 'semi_static_dashboards' }
        format.json { render :json => @contact }
      end
    end
  
    # GET /contacts/new
    # GET /contacts/new.json
    def new
      @contact = Contact.new
      if params[:registration].present?
        @registration = true
        @reason = params[:reason]
      else
        @tag, @seo = Seo.contact(params[:tag_id], I18n.locale.to_s)
      end
      @contact.agreements << Agreement.where(:display => true).locale(I18n.locale.to_s)
  
      respond_to do |format|
        if @registration
          format.html { render 'registration' }
          format.json { render :json => @contact }
        else
          format.html # new.html.erb
          format.json { render :json => @contact }
        end
      end
    end
  
    STRATEGY_TEMPLATES = { :message => :thanks, :registration => :thanks, :download => :check_your_email, :subscriber => :thanks }

    def create
      if params[:contact][:squeeze_id].present?
        @squeeze = Squeeze.find(params[:contact][:squeeze_id])
      end
      @contact = Contact.new(params[:contact].merge(:locale => I18n.locale.to_s))
  
      respond_to do |format|
        if @contact.save
          format.html { render :template => "semi_static/contacts/#{STRATEGY_TEMPLATES[@contact.strategy_sym]}" }
          format.js { render :template => "semi_static/contacts/#{STRATEGY_TEMPLATES[@contact.strategy_sym]}" }
        else
          format.html { render :template => "semi_static/contacts/new" }
          format.json { render :json => @contact.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    # DELETE /contacts/1
    # DELETE /contacts/1.json
    def destroy
      @contact = Contact.find(params[:id])
      @contact.destroy
  
      respond_to do |format|
        format.html { redirect_to contacts_url }
        format.json { head :no_content }
      end
    end
  end
end
