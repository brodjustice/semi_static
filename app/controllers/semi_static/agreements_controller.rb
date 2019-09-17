require_dependency "semi_static/application_controller"

module SemiStatic
  class AgreementsController < ApplicationController
    before_action :authenticate_for_semi_static!

    def index
      @agreements = Agreement.all

      respond_to do |format|
        format.html { render :layout => 'semi_static_dashboards' }
        format.json { render :json => @agreements }
      end
    end

    def show
      @agreement = Agreement.find(params[:id])

      respond_to do |format|
        format.html { render :layout => 'semi_static_dashboards' }
        format.json { render :json => @agreement }
      end
    end

    def edit
      @agreement = Agreement.find(params[:id])
      respond_to do |format|
        format.html { render :layout => 'semi_static_dashboards' }
        format.json { render :json => @agreement }
      end
    end

    def new
      @agreement = Agreement.new

      respond_to do |format|
        format.html { render :layout => 'semi_static_dashboards' }
        format.json { render :json => @agreement }
      end
    end

    def update
      @agreement = Agreement.find(params[:id])

      respond_to do |format|
        if @agreement.update_attributes(agreement_params)
          format.html { redirect_to agreements_path }
          format.json { render :json => @agreement, :status => :created, :location => @agreement }
        else
          format.html { render :layout => 'semi_static_dashboards', :template => "semi_static/agreements/new" }
          format.json { render :json => @agreement.errors, :status => :unprocessable_entity }
        end
      end
    end

    def create
      @agreement = Agreement.new(agreement_params)

      respond_to do |format|
        if @agreement.save
          format.html { redirect_to agreements_path }
          format.json { render :json => @agreement, :status => :created, :location => @agreement }
        else
          format.html { render :layout => 'semi_static_dashboards', :template => "semi_static/agreements/new" }
          format.json { render :json => @agreement.errors, :status => :unprocessable_entity }
        end
      end
    end

    def destroy
      @agreement = Agreement.find(params[:id])

      respond_to do |format|
        if @agreement.destroy
          format.html { redirect_to agreements_url }
          format.json { head :no_content }
        else
          format.html { render :layout => 'semi_static_dashboards', :template => "semi_static/agreements/show" }
          format.json { render :json => @agreement.errors, :status => :unprocessable_entity }
        end
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def agreement_params
      params.fetch(:agreement, {}).permit(:body, :display, :locale, :ticked_by_default, :add_to_subscribers)
    end

  end
end
