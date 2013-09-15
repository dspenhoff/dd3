# controller for 'static' web pages that comprise the site vs. the application 

class SiteController < ApplicationController
  def index
    render :layout => false
  end

  def info
    render :layout => false
  end

  def signin
    render :layout => false
  end
  
  def privacy
    render :layout => false
  end 
     
end
