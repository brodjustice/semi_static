require_dependency "semi_static/application_controller"

module SemiStatic
  class NewsletterDeliveriesController < ApplicationController
    layout 'semi_static_dashboards'

    before_action :authenticate_for_semi_static!

    #
    # Can also be an index of the subscribers newsletter
    # deliveries for a particular newsletter
    #
    def index
      @newsletter = Newsletter.find(params[:newsletter_id])
      if params[:subscriber_id].present?
        @subscriber = Subscriber.find(params[:subscriber_id])
        @deliveries = @newsletter.newsletter_deliveries.where(:subscriber_id => @subscriber.id)
      else
        @deliveries = @newsletter.newsletter_deliveries
      end

      respond_to do |format|
          format.html
          format.js
      end
    end

    def update
      template = 'semi_static/newsletter_deliveries/update'
      @delivery = NewsletterDelivery.find(params[:newsletter_delivery][:id])
      email = NewsletterMailer.publish(@delivery).deliver
      @newsletter = @delivery.newsletter
      @delivery.sent
      if (@delivery = @delivery.newsletter.newsletter_deliveries.pending.first).nil?
        template = 'semi_static/newsletter_deliveries/complete'
      end

      respond_to do |format|
          format.js { render :template => template }
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def newsletter_delivery_params
      params.fetch(:newsletter_delivery, {}).permit(:state)
    end

  end
end
