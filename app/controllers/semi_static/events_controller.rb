require_dependency "semi_static/application_controller"

module SemiStatic
  class EventsController < ApplicationController

    before_action :authenticate_for_semi_static!
    before_action :en_locale_only

    layout 'semi_static_dashboards'

    # GET /events
    # GET /events.json
    def index
      @events = Event.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @events }
      end
    end
  
    # GET /events/1
    # GET /events/1.json
    def show
      @event = Event.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @event }
      end
    end
  
    # GET /events/new
    # GET /events/new.json
    def new
      @event = Event.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @event }
      end
    end
  
    # GET /events/1/edit
    def edit
      @event = Event.find(params[:id])
    end
  
    # POST /events
    # POST /events.json
    def create
      @event = Event.new(event_params)
  
      respond_to do |format|
        if @event.save
          @events = Event.all
          format.html { render 'index', notice: 'Event was successfully created.' }
          format.json { render json: @event, status: :created, location: @event }
        else
          format.html { render action: "new" }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /events/1
    # PUT /events/1.json
    def update
      @event = Event.find(params[:id])
  
      respond_to do |format|
        if @event.update_attributes(event_params)
          @events = Event.all
          format.html { render 'index', notice: 'Event was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /events/1
    # DELETE /events/1.json
    def destroy
      @event = Event.find(params[:id])
      @event.destroy
  
      respond_to do |format|
        format.html { redirect_to events_url }
        format.json { head :no_content }
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.fetch(:event, {}).permit( :name, :description, :location, :location_address, :tz, :door_time, :start_date, :end_date, :duration,
        :in_language, :typical_age_range, :online_url, :attendance_mode, :status,
        :offer_price, :offer_price_currency, :offer_max_price, :offer_min_price,
        :registration, :registration_url, :registration_text)
    end


    # Some helpers require various locale files to be set, so to
    # reduce complexity, only the en locale will be set
    def en_locale_only
      I18n.locale = 'en'
    end

  end
end
