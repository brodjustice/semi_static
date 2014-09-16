require_dependency "semi_static/application_controller"

module SemiStatic
  class AgreementsController < ApplicationController
    before_filter :authenticate_user!, :class => SemiStatic::Contact

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

    def new
      @agreement = Agreement.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @agreement }
      end
    end

    def create
      @agreement = Agreement.new(params[:agreement])

      respond_to do |format|
        if @agreement.save
          format.html { redirect_to agreements_path }
          format.json { render :json => @agreement, :status => :created, :location => @agreement }
        else
          format.html { render :template => "semi_static/agreements/new" }
          format.json { render :json => @agreement.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
end
