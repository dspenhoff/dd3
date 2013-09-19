# Copyright (c) by David M. Spenhoff. All rights reserved

class ScenariosController < ApplicationController
  
  before_filter :login_required
	
  # GET /scenarios
  def index
    @page_title = "Scenarios"
  end
end