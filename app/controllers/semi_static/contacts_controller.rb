require_dependency "semi_static/application_controller"

module SemiStatic
  class ContactsController < ApplicationController

    before_filter :authenticate_for_semi_static!, :except => [:new, :create]
  
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
      @contact.agreements << Agreement.where(:display => true).locale(I18n.locale.to_s)
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @contact }
      end
    end
  
    # POST /contacts
    # POST /contacts.json
    def create
      @contact = Contact.new(params[:contact])
  
      respond_to do |format|
        if @contact.save
          format.html { render :template => 'semi_static/contacts/thanks' }
          format.json { render :json => @contact, :status => :created, :location => @contact }
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
