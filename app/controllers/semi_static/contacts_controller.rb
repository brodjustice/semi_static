require_dependency "semi_static/application_controller"

module SemiStatic
  class ContactsController < ApplicationController

    before_action :authenticate_for_semi_static!, :except => [:new, :create]

    # Caching the contact form is not straight forword in later versions for Rails (4+)
    # as the CSFR policies mean that the AUTH_CODE will quickly become invalid causing
    # an ActionController::InvalidAuthenticityToken exception. We never cached the
    # contact for if it was a registration anyway, eg:
    #   Don't cache the registration page as this is dynamic
    #     caches_page :new, :unless => Proc.new { |c| c.request.url.include?('registration') }
    # But right now we will just not cache anymore and look at other strategies in future,
    # for example fragment caching in the view my be sufficient.
  
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
        @contact = Contact.new(contact_params.merge(:locale => I18n.locale.to_s))

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

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.fetch(:contact, {}).permit(:reason, :surname, :message, :email, :telephone, :name, :locale, :agreement_ids,
        :strategy, :squeeze_id, :title, :company, :address, :position, :country, :employee_count, :branch, :agreement_ids => [])
    end


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
