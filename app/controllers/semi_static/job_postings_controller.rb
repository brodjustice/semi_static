require_dependency "semi_static/application_controller"

module SemiStatic
  class JobPostingsController < ApplicationController
    before_action :set_job_posting, only: [:edit, :update, :destroy]
    before_action :authenticate_for_semi_static!

    layout 'semi_static_dashboards'

    # GET /job_postings
    def index
      @job_postings = JobPosting.all
    end

    # GET /job_postings/1
    # def show
    # end

    # GET /job_postings/new
    def new
      @job_posting = JobPosting.new(:salary_currency => 'EUR')
    end

    # GET /job_postings/1/edit
    def edit
    end

    # POST /job_postings
    def create
      @job_posting = JobPosting.new(job_posting_params)

      if @job_posting.save
        redirect_to job_postings_path, notice: 'Job posting was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /job_postings/1
    def update
      if @job_posting.update(job_posting_params)
        redirect_to job_postings_path, notice: 'Job posting was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /job_postings/1
    def destroy
      @job_posting.destroy
      redirect_to job_postings_url, notice: 'Job posting was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_job_posting
        @job_posting = JobPosting.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def job_posting_params
        params.fetch(:job_posting, {}).permit(:title, :description, :responsibilities, :base_salary, :estimated_salary,
          :date_posted, :employment_type, :industry, :qualifications, :salary_currency, :job_location, 
          :skills, :url, :organisation_name, :organisation_address, :organisation_department,
          :organisation_email, :organisation_telephone,
          :organisation_legal_name, :organisation_location, :organisation_logo, :organisation_description)
      end
  end
end
