# Copyright (c) by David M. Spenhoff. All rights reserved

class UsersController < ApplicationController

	before_filter :authenticate_admin_user
	
  def index
  	@users = User.all
  	@page_title = "Users"
  end

  def new
  	@user = User.new
  	@page_title = "User > New"
  end

  def create
    @user = User.new(params[:user], :without_protection => true)
		
		if @user.save
			flash[:notice] = 'User was successfully created'
			redirect_to(users_path)
		else
			render :action => "new"
		end
  end

  def show
    @user = User.find(params[:id])
		@page_title = "User > View"
	end
	
	def edit
		@user = User.find(params[:id])
		@page_title = "User > Edit"
	end
	
  def update
    @user = User.find(params[:id])

		if @user.update_attributes(params[:user], :without_protection => true)
			flash[:notice] = 'User was successfully updated'
			redirect_to(@user)
		else
			render :action => "edit"
		end
  end	

  def destroy
    @user = User.find(params[:id])
   	@user.destroy
		redirect_to(users_url) 
  end  	

  protected
  
  def admin_user
  	# returns the database object associated with the special user 'admin'
		User.find(:first, :conditions => "role = 'Admin'")  
  end
  
  def authenticate_admin_user
  	# restricts user management to authorized users
  	# user must be signed in and username must be 'admin'
  	if logged_in?
  		# user is signed in, is user 'admin' 
  		return true
  		#return true if admin_user.id == @current_user.id
  		flash[:notice] = 'Administration features are not authorized for this user'
  		redirect_to :admin_index and return false
  	end
  	
  	# not signed in, send to sign in page
  	session[:return_to] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
  	redirect_to new_session_path and return false  	
  end

end
