# Copyright (c) by David M. Spenhoff. All rights reserved

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  before_filter :fetch_logged_in_user
  
  protected
  
  def fetch_logged_in_user
  	return unless session[:user_id]
  	@current_user = User.find_by_id(session[:user_id])
  end
  
  def logged_in?
  	! @current_user.nil?
  end
  helper_method :logged_in?
  
  def login_required
  	return true if logged_in?
  	session[:return_to] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
  	redirect_to new_session_path and return false
  end
  
  def list_conditions
  	# build the conditions string to modify the campaign selection in the index method
  	# returns empty string if no params are present
  	
  	# note that this action can be used with *any* subset of the specified parameters
  	# so this same action can be used for modifying lists of campaigns, activities,
  	# groups, etc., which is why it is here in the application_controller
  	
  	conditions = ""
		conditions_applied = false
		
		params_mgrname = params[:mgrname]
		params_scope = params[:scope]
		params_status = params[:status]
  	
  	# apply manager name condition if it is present
  	if params_mgrname != nil && params_mgrname != ""
  		conditions = "manager = '" + params_mgrname + "'"
  		conditions_applied = true
  	end
  	
  	# apply scope condition if it is present
  	if params_scope != nil && params_scope != ""
  		if !conditions_applied
  			conditions = "scope = '" + params_scope + "'"
  			conditions_applied = true
  		else
  			conditions += " and scope = '" + params_scope + "'"
  		end
  	end
  	
  	# apply status condition if it is present
  	if params_status != nil && params_status != ""
  		if !conditions_applied
  			conditions = "status = '" + params_status + "'"
  		else
  			conditions += " and status = '" + params_status + "'"
  		end
  	end 
  	
  	conditions	# the return value  	
  end


  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
