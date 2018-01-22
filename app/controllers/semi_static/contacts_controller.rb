require_dependency "semi_static/application_controller"

module SemiStatic
  class ContactsController < ApplicationController

    before_filter :authenticate_for_semi_static!, :except => [:new, :create]

    # Don't cache the registration page as this is dynamic
    caches_page :new, :if => Proc.new { |c| c.request.url.include?('registration') }
  
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

      # Check if we are trying to stop spambots
      unless spam_check(params)
        @contact = Contact.new(params[:contact].merge(:locale => I18n.locale.to_s))

        # Add any custom params
        @contact.custom_params = params[:custom_params]
      end

      respond_to do |format|
        if !@contact.errors.present? && @contact.save
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

    private

    def spam_check(params)
      spam_detected = false
      if params[:message].present? && SemiStatic::Engine.config.contact_form_spam_fields && (params[:message][:message].present? || params[:message][:homepage].present?)
        @contact = Contact.new(:email => params[:contact][:email])
        @contact.errors.add(:base, 'This appears to be SPAM. Sorry, we cannot process this request')
        spam_detected = true
      elsif SemiStatic::Engine.config.contact_form_spam_email
        strs = SemiStatic::Engine.config.contact_form_spam_email.split(',')
        if params[:contact].present? && params[:contact][:email].present? && strs.any?{|word| params[:contact][:email].include?(word.strip)}
          @contact = Contact.new(:email => params[:contact][:email])
          @contact.errors.add(:base, 'This appears to be SPAM. Sorry, we cannot process this request, please send email to '+ SemiStatic::Engine.config.info_email)
          spam_detected = true
        end
      end
      spam_detected
    end
  end
end
