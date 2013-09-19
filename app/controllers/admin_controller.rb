# Copyright (c) by David M. Spenhoff. All rights reserved

class AdminController < ApplicationController

	before_filter :login_required
	
	def index
		@page_title = "Administration"
	end
end
