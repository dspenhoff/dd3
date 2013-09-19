# Copyright (c) by David M. Spenhoff. All rights reserved

include SharedMethods

class RegionsController < ApplicationController
  
  before_filter :login_required
	
  # GET /regions
  def index
    @regions = Region.all
    @order_by = "none"
    @page_title = "Regions"
  end

  # GET /regions/1
  def show
    @region = Region.find(params[:id])
    @sim = Simulation.new
    @sim.simulate(@region.deals, 'mode', 'given', nil, 1.0, nil, nil, nil)
    @page_title = "Regions > Show"
  end  
  
  # GET /regions/new
  def new
    @region = Region.new
    @page_title = "Regions > New"
  end

  # GET /regions/1/edit
  def edit
    @region = Region.find(params[:id])
    @page_title = "Regions > Edit"
  end

  # POST /regions
  def create
    @region = Region.new(params[:region], :without_protection => true)
    if @region.save
      flash[:notice] = 'Region was successfully created'
      redirect_to(@region)
    else
      render :action => "new" 
    end
  end

  # PUT /regions/1
  def update
    @region = Region.find(params[:id])
    if @region.update_attributes(params[:region], :without_protection => true)
      flash[:notice] = 'Region was successfully updated'
      redirect_to(@region) 
    else
      render :action => "edit" 
    end
  end

  # DELETE /regions/1
  def destroy
    # confirm that the region is empty (no reps -> no deals) defore deleting
    @region = Region.find(params[:id])
    if @region.reps == []   # if region is empty it can be deleted
      @region.destroy
      destroy_notice = "Rep was successfully deleted"      
    else
      destroy_notice = "Rep has assigned reps deals and cannot be deleted"
    end
    flash[:notice] = destroy_notice
    redirect_to(regions_url)
  end
  
  def show_associated_reps
    @reps = Region.find(params[:id]).reps
    @page_title = "Regions > View reps"
    render "reps/index"
  end
  
  def show_associated_deals
    @order_by = "none"
    session[:order_by] = "id"
    @page_title = "Regions > View deals"
    show_region_deals
  end
  
  # orders the deals according to the given parameters
  # uses in-database functions to handle teh sorting
  def order_region_deals
    @order_by = params[:order_by]
    order_deals_by(@order_by)   # shared
    show_region_deals
  end
  
  # gets and renders ordered region deals using the deals/index view
  def show_region_deals
    @region = Region.find(params[:id])
    @deals = @region.deals.all(:order => session[:order_by])
    flash.now[:notice] = @deals.length.to_s + " deals" 
    @page_title = "Region > View deals (" + @region.name + ")"
    @regions_controller = true
    render "deals/index"  # display using deals controller/formatting
  end
  
  # sorts the regions according to the order_by parameter
  # in deals, order_by is accomplished in the database call
  # here some of the sort fields are not database fields so
  # a different approach is needed here
  # - based on the order_by parameter sort a tracking array containing the appropriate value
  # - then apply the sort order to the @reps array according to the sorted tracking index  def order_regions
  def order_regions
    regions = Region.all
    @order_by = params[:order_by]

    # create the sorted tracking array according to the ordering parameter
    case @order_by 
    when "num_deals"
      sorted = regions.length.times.collect{ |i| [regions[i].num_deals, i] }.sort!
    when "num_forecast"
      sorted = regions.length.times.collect{ |i|  [regions[i].num_forecast, i] }.sort!
    when "pipeline"
      sorted = regions.length.times.collect{ |i|  [regions[i].current_pipeline, i] }.sort!
    when "forecast"
      sorted = regions.length.times.collect{ |i|  [regions[i].current_forecast, i] }.sort!
    when "accuracy"
      sorted = regions.length.times.collect{ |i|  [regions[i].forecast_accuracy, i] }.sort!
    when "current_coverage"
      sorted = regions.length.times.collect{ |i|  [regions[i].current_forecast_coverage, i] }.sort!
    when "historical_coverage"
      sorted = regions.length.times.collect{ |i|  [regions[i].forecast_coverage, i] }.sort!
    else
      # default (eg, order_by = none)
      sorted = regions.length.times.collect{ |i|  [regions[i].id, i] }.sort! 
    end      
 
    if @order_by != "none" then sorted.reverse! end
    
    # apply the sort order index to the reps array
    @regions = sorted.length.times.collect{ |i| regions[sorted[i][1]] }
    
    @page_title = "Regions"
    render :index
  end
  
  #
  # utilities used to set up the reps/regions/histories relationships when a new scenario is generated
  #
  
  # batch assignment of region_id, called once and/or as needed
  # could delete
  def set_region_id
    reps = Rep.all
    regions = Region.all
    reps.each do |rep|
      regions.each do |region|
        if rep.region_name == region.name
          rep.region_id = region.id
          rep.save
          break
        end
      end
    end
  end

end
