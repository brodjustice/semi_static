require 'csv'
require_dependency "semi_static/application_controller"

module SemiStatic
  class SubscribersController < ApplicationController

    before_filter :authenticate_for_semi_static!, :except => [:edit, :update]
    layout 'semi_static_dashboards'

    # GET /subscribers
    # GET /subscribers.json
    def index
      @subscribers = Subscriber.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @subscribers }
      end
    end
  
    # GET /subscribers/1
    # GET /subscribers/1.json
    def show
      @subscriber = Subscriber.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @subscriber }
      end
    end
  
    # GET /subscribers/new
    # GET /subscribers/new.json
    def new
      if params[:cmd] == 'csv'
        # Nothing to do, this must be a js format request
      else
        @subscriber = Subscriber.new
      end
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @subscriber }
        format.js
      end
    end
  
    # GET /subscribers/1/edit
    def edit
      if params[:token]
        if (@subscriber = SemiStatic::Subscriber.find_by_cancel_token(params[:token])).blank?
          layout = 'semi_static_application'; template = 'semi_static/subscribers/token_not_found';
        else
          layout = 'semi_static_application'; template = 'semi_static/subscribers/cancel';
        end
      elsif semi_static_admin?
        @subscriber = Subscriber.find(params[:id])
        layout = 'semi_static_dashboards'; template = 'semi_static/subscribers/edit';
      end

      respond_to do |format|
        format.html { render :template => template, :layout => layout }
        format.json { render json: @subscriber }
      end
    end
  
    # POST /subscribers
    # POST /subscribers.json
    def create
      if params[:cmd] == 'csv'
        @errors = []
        CSV.read(params[:csv].path).each{|row|
          @subscriber = Subscriber.create(:name => row[0], :surname => row[1], :email => row[2], :telephone => row[3], :locale => params[:locale])
          unless @subscriber.errors.empty?
            @errors << {:error => @subscriber.errors, :name => row[0], :surname => row[1], :email => row[2], :telephone => row[3]}
          end
        }
        notice = 'Subscribers CSV imported with ' + @errors.size.to_s + ' errors'
      else
        @subscriber = Subscriber.create(params[:subscriber])
        notice = 'Subscriber was successfully created.'
      end

      @subscribers = Subscriber.all
  
      respond_to do |format|
        if (params[:cmd] == 'csv') || @subscriber.errors.empty?
          format.html { render action: 'index', notice: notice }
          format.json { render json: @subscriber, status: :created, location: @subscriber }
        else
          format.html { render action: "new" }
          format.json { render json: @subscriber.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /subscribers/1
    # PUT /subscribers/1.json
    def update
      if params[:cancel]
        @subscriber = SemiStatic::Subscriber.find_by_cancel_token(params[:token])
        if @subscriber && @subscriber.destroy
          layout = 'semi_static_application'; template = 'semi_static/subscribers/cancel_success';
          deleted = true
        else
          layout = 'semi_static_application'; template = 'semi_static/subscribers/cancel';
        end
      elsif authenticate_for_semi_static!
        @subscriber = SemiStatic::Subscriber.find(params[:id])
        layout = 'semi_static_dashboards'; template = 'semi_static/subscribers/show';
      end
  
      respond_to do |format|
        if deleted
          format.html { render :template => template, :layout => layout }
        elsif @subscriber.update_attributes(params[:subscriber])
          format.html { render :template => template, :layout => layout }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @subscriber.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /subscribers/1
    # DELETE /subscribers/1.json
    def destroy
      @subscriber = Subscriber.find(params[:id])
      @subscriber.delete
  
      respond_to do |format|
        format.html { redirect_to subscribers_url }
        format.json { head :no_content }
      end
    end
  end
end
