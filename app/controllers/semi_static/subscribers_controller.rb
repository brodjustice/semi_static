require 'csv'
require_dependency "semi_static/application_controller"

module SemiStatic
  class SubscribersController < ApplicationController

    before_filter :authenticate_for_semi_static!, :except => [:edit, :update]
    layout 'semi_static_dashboards'

    # GET /subscribers
    # GET /subscribers.json
    def index
      template = 'index'
      if params[:unsubscribed] == 'true'
        @subscribers = Subscriber.where(:unsubscribe => :true)
        template = 'unsubscribers'
      else
        @subscribers = Subscriber.where(:unsubscribe => :false)
      end
  
      respond_to do |format|
        format.html { render :template => "semi_static/subscribers/#{template}" }
        format.json { render json: @subscribers }
        format.csv {
          filename = SemiStatic::Engine.config.site_name + 'subscibers.csv'
          headers["Content-Type"] ||= 'text/csv'
          headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
          render :layout => false
        }
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
      if ['csv', 'bounced'].any?{|c| params[:cmd] && params[:cmd].include?(c) }
        # Nothing to do, this must be a js format request
      else
        @subscriber = Subscriber.new(params[:subscriber])
      end
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @subscriber }
        format.js { render :template => "semi_static/subscribers/#{params[:cmd]}" }
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
        r = 1
        @added_count = 0
        begin
          CSV.read(params[:csv].path, :encoding => 'bom|utf-8').each{|row|
            @subscriber = Subscriber.create(:name => row[0], :surname => row[1], :email => row[2], :telephone => row[3],
              :locale => params[:locale], :subscriber_category_id => params[:subscriber_category_id])
            unless @subscriber.errors.empty?
              @errors << {:error => @subscriber.errors, :name => row[0], :surname => row[1], :email => row[2], :telephone => row[3]}
            else
              @added_count += 1
            end
            r = row
          }
          notice = 'Subscribers CSV imported with ' + @errors.size.to_s + ' errors'
        rescue ArgumentError
          utf_encoding_error
        end
      elsif params[:cmd] == 'bounced'
        @errors = []
        r = 1
        @added_count = 0
        begin
          CSV.read(params[:csv].path, :encoding => 'bom|utf-8').each{|row|
            @subscriber = Subscriber.find_by_email(row[0])
            if @subscriber.nil?
              @errors << {:error => 'Email not found', :name => row[1], :surname => row[2], :email => row[0]}
              next
            end
            category = SubscriberCategory.find(params[:subscriber_category_id])
            @subscriber.category = category
            @subscriber.unsubscribe = true
            @subscriber.bounced = true
            @subscriber.save
            unless @subscriber.errors.empty?
              @errors << {:error => @subscriber.errors, :name => row[1], :surname => row[2], :email => row[0]}
            else
              @added_count += 1
            end
            r = row
          }
          notice = 'Bounced Subscribers CSV imported with ' + @errors.size.to_s + ' errors'
        rescue ArgumentError
          utf_encoding_error
        end
      else
        @subscriber = Subscriber.create(params[:subscriber])
        unsubscribed = params[:subscriber]
        notice = 'Subscriber was successfully created.'
      end

      @subscribers = Subscriber.all

      template = 'index'

      @subscriber && @subscriber.unsubscribe && template = 'unsubscribers'

      respond_to do |format|
        if ['csv', 'bounced'].any?{|c| (params[:cmd] && params[:cmd].include?(c)) } || @subscriber.errors.empty?
          format.html { render template: "semi_static/subscribers/#{template}", notice: notice }
          format.json { render json: @subscriber, status: :created, location: @subscriber }
        else
          format.html { render action: "new" }
          format.json { render json: @subscriber.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /subscribers/1
    # PUT /subscribers/1.json
    #
    # TODO: Got very messy, refactor
    #
    def update
      if params[:cancel]
        @subscriber = SemiStatic::Subscriber.find_by_cancel_token(params[:token])
        if @subscriber && !@subscriber.unsubscribe && @subscriber.unsubscribe = true
          @subscriber.save
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

    private

    def utf_encoding_error
      @subscriber = Subscriber.new
      @subscriber.errors[:base] << 'File is not UTF-8 codeing, please convert to UTF-8 encoding'
      @errors << {:error => @subscriber.errors, :name => "row #{r}", :surname => 'unreadable', :email => 'unreadable', :telephone => 'unreadable'}
      notice = 'Subscribers CSV import FAILED with ' + @errors.size.to_s + ' errors'
    end

    def validate_encodeing(csv_path, errors)
      row = 0
      begin
        CSV.read(csv_path, :encoding => 'bom|utf-8').each{|r| row = r}
      rescue ArgumentError
        @errors << {:error => 'File is not UTF-8 codeing, please convert to UTF-8 encoding', :name => "row #{row}", :surname => 'unreadable', :email => 'unreadable', :telephone => 'unreadable'}
      end
      errors.empty?
    end
  end
end
