require_dependency "semi_static/application_controller"

module SemiStatic
  class CommentsController < ApplicationController

    before_filter :authenticate_for_semi_static!,  :only => [ :show, :update, :delete ]

    # GET /comments.json
    def index
      if params[:entry_id].present?
        @entry = Entry.find(params[:entry_id])
        @comments = @entry.comments.all
        @comment = @entry.comments.new(params[:comment])
        layout = 'semi_static_application'
        template = 'semi_static/comments/index'
      elsif semi_static_admin?
        @comments = Comment.order('created_at DESC')
        layout = 'semi_static_dashboards'
        template = 'semi_static/comments/admin_index'
      end
  
      respond_to do |format|
        format.html {
          if @entry.present?
            redirect_to entry_path(@entry, :anchor => "comments")
          else
            render :template => template, :layout => layout
          end
        }
        format.js
        format.json { render json: @comments }
      end
    end

    # GET /comments/1
    # GET /comments/1.json
    def show
      @comment = Comment.find(params[:id])
  
      respond_to do |format|
        format.html { render :layout => 'semi_static_dashboards' }
        format.json { render json: @comment }
      end
    end
  
    # GET /comments/1/edit
    def edit
      @comment = Comment.find(params[:id])
    end
  
    # POST /comments
    # POST /comments.json
    def create
      @entry = Entry.find(params[:entry_id])
      @comment = @entry.comments.new(params[:comment])

      respond_to do |format|
        if @comment.save
          @comment =  @entry.comments.new
          format.html { redirect_to entry_path(@entry, :anchor => "comment_id_#{@comment.id}") }
          format.js { render 'semi_static/comments/index' }
          format.json { render json: @comment, status: :created, location: @comment }
        else
          format.html { render :template => 'semi_static/entries/show', :layout => 'semi_static_application', :anchor => 'comments'}
          format.js { render 'semi_static/comments/form' }
          format.json { render json: @comment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /comments/1
    # PUT /comments/1.json
    def update
      @comment = Comment.find(params[:id])
  
      respond_to do |format|
        if @comment.update_attributes(params[:comment])
          format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @comment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /comments/1
    # DELETE /comments/1.json
    def destroy
      @comment = Comment.find(params[:id])
      @comment.destroy
  
      respond_to do |format|
        format.html { redirect_to comments_url }
        format.json { head :no_content }
      end
    end
  end
end
