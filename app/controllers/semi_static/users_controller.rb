require_dependency "semi_static/application_controller"

module SemiStatic
  class UsersController < ApplicationController

    before_filter :authenticate_user!
  
    layout 'semi_static_dashboards'
  
    def index
      @users = User.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @users }
      end
    end
  
    def show
      @user = User.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render :json => @user }
      end
    end
  
    def new
      @user = User.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @user }
      end
    end
  
    def edit
      @user = User.find(params[:id])
    end
  
    def create
      @user = User.new(params[:user])
  
      respond_to do |format|
        if @user.save
          format.html { redirect_to @user, :notice => 'User was successfully created.' }
          format.json { render :json => @user, :status => :created, :location => @user }
        else
          format.html { render :action => "new" }
          format.json { render :json => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    def update
      @user = User.find(params[:id])
  
     # Would like this to be in the model as a before_save but Devise does its work before we can
      # call before_save in the model, so sod it:
      # https://github.com/plataformatec/devise/wiki/How-To%3a-Allow-users-to-edit-their-account-without-providing-a-password
      normalise_params(params)
  
      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to @user, :notice => 'User was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render :action => "edit" }
          format.json { render :json => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  
    def destroy
      @user = User.find(params[:id])
      @user.destroy
  
      respond_to do |format|
        format.html { redirect_to users_url }
        format.json { head :no_content }
      end
    end
  
    private
  
    def normalise_params(params, current_user = User.new)
      # Remove password from form input if blank
      if params[:user][:password].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      params
    end
  end
end
