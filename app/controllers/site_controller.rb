class SiteController < ApplicationController
  def duckhome
    render :layout => false
  end

  def duckinfo
    render :layout => false
  end

  def ducksignin
    render :layout => false
  end
end
