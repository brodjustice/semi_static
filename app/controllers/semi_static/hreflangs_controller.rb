require_dependency "semi_static/application_controller"

module SemiStatic
  class HreflangsController < ApplicationController

    before_action :authenticate_for_semi_static!

    # GET /hreflangs
    # GET /hreflangs.json
    def index
      @hreflangs = Hreflang.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @hreflangs }
      end
    end
  
    # GET /hreflangs/new
    # GET /hreflangs/new.json
    def new
      @seo = Seo.find(params[:seo_id])
      @hreflang = @seo.hreflangs.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.js
      end
    end
  
    # GET /hreflangs/1/edit
    def edit
      if params[:tag_id].present?
        # 
        # This is not going to actually change the Seo, rather it will
        # offer to select the equivalant lang SemiStatic::Tag. This is
        # done directly in the Tag model, no Seo model is required at
        # this point.
        #
        @tag = Tag.find(params[:tag_id])
        @html_template = 'semi_static/hreflangs/edit_hreflang_tags'
      else
        @seo = Seo.find(params[:seo_id])
        @hreflang = Hreflang.find(params[:id])
        @html_template = 'semi_static/hreflangs/edit'
      end

      respond_to do |format|
        format.html
        format.js
      end
    end
  
    # POST /hreflangs
    # POST /hreflangs.json
    def create
      @seo = Seo.find(params[:seo_id])
      @hreflang = @seo.hreflangs.new(hreflang_params)

      respond_to do |format|
        if @hreflang.save
          format.html { redirect_to seos_path(), notice: 'Hreflang was successfully created.' }
          format.json { render json: @hreflang, status: :created, location: @hreflang }
        else
          format.html { redirect_to seos_path(), notice:  ['WARNING', @hreflang.errors.full_messages.first].join(' ') }
          format.json { render json: @hreflang.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /hreflangs/1
    # PUT /hreflangs/1.json
    def update
      @hreflang = Hreflang.find(params[:id])
  
      respond_to do |format|
        if @hreflang.update_attributes(hreflang_params)
          format.html { redirect_to seos_path(), notice: 'Hreflang was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { redirect_to seos_path(), notice:  ['WARNING', @hreflang.errors.full_messages.first].join(' ') }
          format.json { render json: @hreflang.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /hreflangs/1
    # DELETE /hreflangs/1.json
    def destroy
      @seo = Seo.find(params[:seo_id])
      @hreflang = Hreflang.find(params[:id])
      @hreflang.destroy
  
      respond_to do |format|
        format.html { redirect_to seos_path(), notice: 'Hreflang was deleted.' }
        format.json { head :no_content }
      end
    end

    private

    def hreflang_params
      params.fetch(:hreflang, {}).permit(:href, :locale, :seo_id)
    end
  end
end
