require_dependency "semi_static/application_controller"

module SemiStatic
  class SubscriberCategoriesController < ApplicationController

    before_action :authenticate_for_semi_static!
    layout 'semi_static_dashboards'

    def new
      @subscriber_category = SubscriberCategory.new
  
      respond_to do |format|
        format.html
        format.js
      end
    end
  
    def create
      @subscriber = SubscriberCategory.create(subscriber_category_params)
      notice = 'Subscriber Category was successfully created.'

      respond_to do |format|
        format.html { redirect_to subscribers_path }
      end
    end
  
    def destroy
      @subscriber_cateogory = SubscriberCategory.find(params[:id])
      @subscriber_cateogory.delete
  
      respond_to do |format|
        format.html { redirect_to subscribers_url }
        format.json { head :no_content }
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subscriber_category_params
      params.fetch(:subscriber_category, {}).permit(:name)
    end

  end
end
