require_dependency "semi_static/application_controller"

module SemiStatic
  class ClickAdsController < ApplicationController

    before_filter :authenticate_for_semi_static!
    before_filter :set_return_path

    caches_page :show

    layout 'semi_static_dashboards'

    # GET /click_ads
    # GET /click_ads.json
    def index
      @click_ads = ClickAd.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @click_ads }
      end
    end
  
    # GET /click_ads/1
    # GET /click_ads/1.json
    def show
      @click_ad = ClickAd.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @click_ad }
      end
    end
  
    # GET /click_ads/new
    # GET /click_ads/new.json
    def new
      @click_ad = ClickAd.new
      @click_ad.entry = @entry = Entry.find(params[:entry_id])
  
      respond_to do |format|
        format.html # new.html.erb
        format.js
        format.json { render json: @click_ad }
      end
    end
  
    # GET /click_ads/1/edit
    def edit
      @click_ad = ClickAd.find(params[:id])

      respond_to do |format|
        format.html { redirect_to params[:return] || click_ads_path }
        format.js
      end

    end
  
    # POST /click_ads
    # POST /click_ads.json
    def create
      @click_ad = ClickAd.new(params[:click_ad])
      @click_ad.entry = Entry.find(params[:entry_id])
  
      respond_to do |format|
        if @click_ad.save
          format.html { redirect_to @click_ad, notice: 'Click ad was successfully created.' }
          format.json { render json: @click_ad, status: :created, location: @click_ad }
        else
          format.html { render action: "new" }
          format.json { render json: @click_ad.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /click_ads/1
    # PUT /click_ads/1.json
    def update
      @click_ad = ClickAd.find(params[:id])
  
      respond_to do |format|
        if @click_ad.update_attributes(params[:click_ad])
          format.html { redirect_to params[:return] || click_ads_path, :notice => 'SEO meta tags updated' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @click_ad.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /click_ads/1
    # DELETE /click_ads/1.json
    def destroy
      @click_ad = ClickAd.find(params[:id])
      @click_ad.destroy
  
      respond_to do |format|
        format.html { redirect_to click_ads_url }
        format.json { head :no_content }
      end
    end

    private

    def set_return_path
      @return = params[:return]
    end

  end
end
