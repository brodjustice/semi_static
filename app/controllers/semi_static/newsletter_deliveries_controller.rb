require_dependency "semi_static/application_controller"

module SemiStatic
  class NewsletterDeliveriesController < ApplicationController
    layout 'semi_static_dashboards'

    before_filter :authenticate_for_semi_static!

    def index
      @newsletter = Newsletter.find(params[:newsletter_id])
      @deliveries = @newsletter.newsletter_deliveries
    end

    def update
      template = 'semi_static/newsletter_deliveries/update'
      @delivery = NewsletterDelivery.find(params[:newsletter_delivery][:id])
      email = NewsletterMailer.publish(@delivery).deliver
      newsletter = @delivery.newsletter
      @delivery.sent
      if (@delivery = @delivery.newsletter.newsletter_deliveries.pending.first).nil?
        template = 'semi_static/newsletter_deliveries/complete'
        newsletter.email_object_to_file(email)
      end

      respond_to do |format|
          format.js { render :template => template }
      end
    end
  end
end
