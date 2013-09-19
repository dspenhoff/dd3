# Copyright (c) by David M. Spenhoff. All rights reserved

class SessionsController < ApplicationController
  def new
  	@page_title = "Sign in"
  	render :layout => 'site'
  end

  def create

  	@current_user = User.find_by_username_and_password(params[:username], params[:password])
  	
  	if @current_user
  		session[:user_id] = @current_user.id
      @page_title = "Sign in > Success"
      render :action => 'signin_success'
  	else
  		flash.now[:notice] = "Sign in error, please try again"
  		render :action => 'new', :layout => 'site'
  	end
  end

  def destroy
  	session[:user_id] = @current_user = nil
  	#@page_title = "Signed out > Success"
  	#render :action => 'signout_success'
  end
  
  def index
    @page_title = "Signed out > Success"
  	render :action => 'signout_success'
  end
  
end

