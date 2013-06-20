# Copyright © by David M. Spenhoff. All rights reserved

include SharedMethods
require "simulation"			# simulates deals

class RepsController < ApplicationController
  # GET /reps
  def index
    @reps = Rep.all
    @order_by = "none"
    @page_title = "Reps"
  end
  
  # GET /reps/1
  def show
    @rep = Rep.find(params[:id])
    @sim = Simulation.new
    @sim.simulate(@rep.deals, 'mode', 'given', nil, 1.0, nil, nil, nil)
    @page_title = "Reps > Show"
  end

  # GET /reps/new
  def new
    @rep = Rep.new
    @regions = Region.all     # for the collection_select
    @page_title = "Reps > New"
  end

  # GET /reps/1/edit
  def edit
    @rep = Rep.find(params[:id])
    @regions = Region.all     # for the collection_select
    @page_title = "Reps > Edit"
  end

  # POST /reps
  def create
    @rep = Rep.new(params[:rep], :without_protection => true)
    if @rep.save
      flash[:notice] = 'Rep was successfully created.'
      redirect_to(@rep)
    else
      render :action => "new" 
    end
  end

  # PUT /reps/1
  def update
    @rep = Rep.find(params[:id])
    if @rep.update_attributes(params[:rep], :without_protection => true)
      flash[:notice] = 'Rep was successfully updated.'
      redirect_to(@rep) 
    else
      render :action => "edit" 
    end
  end

  # DELETE /reps/1
  def destroy
    # confirm that the rep is empty (no deals) before deleting
    @rep = Rep.find(params[:id])
    if @rep.deals == []   # if rep is empty it can be deleted
      @rep.destroy
      destroy_notice = "Region was successfully deleted"      
    else
      destroy_notice = "Region has assigned reps or deals and cannot be deleted"
    end
    flash[:notice] = destroy_notice
    redirect_to(reps_url)
  end
  
  #
  # methods to show the rep's associated deals and histories
  #

  # show the deals that belong to the given rep
  def show_associated_deals
    @order_by = "none"
    session[:order_by] = "id"
    show_rep_deals
  end
  
  # orders the deals according to the given parameters
  def order_rep_deals
    @order_by = params[:order_by]   # parameter returned to the view
    order_deals_by(@order_by)   # shared
    show_rep_deals
  end
  
  # gets and renders ordered rep deals with the deals/index view
  def show_rep_deals
    @rep = Rep.find(params[:id])
    @deals = @rep.deals.all(:order =>session[:order_by])
    flash.now[:notice] = @deals.length.to_s + " deals" 
    @page_title = "Rep > View deals (" + @rep.name + ")"
    @reps_controller = true
    render "deals/index"  # display using deals controller/formatting
  end
  
  def show_associated_histories
    @rep = Rep.find(params[:id])
    @histories = @rep.histories
    @page_title = "Reps > View history"
    #flash.now[:notice] = "Viewing history for rep " + @rep.name
  end
  
  # sorts the reps according to the order_by parameter
  # in deals, order_by is accomplished in the database call
  # here some of the sort fields are not database fields so
  # a different approach is needed:
  # - based on the order_by parameter sort a tracking array containing the appropriate value
  # - then apply the sort order to the @reps array according to the sorted tracking index
  def order_reps    
    reps = Rep.all
    @order_by = params[:order_by]
    
    # create a sorted tracking array according to the ordering parameter
    case @order_by 
    when "num_deals"
      sorted = reps.length.times.collect{ |i| [reps[i].num_deals, i]}.sort!
    when "num_forecast"
      sorted = reps.length.times.collect{ |i| [reps[i].num_forecast, i]}.sort!
    when "pipeline"
      sorted = reps.length.times.collect{ |i| [reps[i].current_pipeline, i]}.sort!
    when "forecast"
      sorted = reps.length.times.collect{ |i| [reps[i].current_forecast, i]}.sort!
    when "accuracy"
      sorted = reps.length.times.collect{ |i| [reps[i].forecast_accuracy, i]}.sort!
    when "rank"
      sorted = reps.length.times.collect{ |i| [reps[i].rank_value, i]}.sort!
    else
      # default (eg, order_by = none)
      sorted = reps.length.times.collect{ |i| [reps[i].id, i] }.sort!
    end      
        
    if @order_by != "none" && @order_by != "rank" then sorted.reverse! end
    
    # apply the sort order index to the reps array
    @reps = sorted.length.times.collect{ |i| reps[sorted[i][1]] }
    @page_title = "Reps"
    render :index
  end
  

  
end
