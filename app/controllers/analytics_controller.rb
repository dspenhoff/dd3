# Copyright © by David M. Spenhoff. All rights reserved.


require "visualization"		# charts 
require "summary"					# summaries 
require "simulation"			# simulations
require "regression"      # linear regressions

class AnalyticsController < ApplicationController
  
  def index
    @page_title = 'Analytics'
  end
  
  #
  # methods for summaries
  #
  
  # summarizes all deals 
  def summarize_deals
    @deals = Deal.all
    @show_predicted = false
    summarize_all(filtered_deals("", "all", @deals))
    flash.now[:notice] = "Summary for all open deals"
    @page_title = "Analytics > Summarize deals"
  end
  
  def summarize_all(deals)
    # get the non-simulated summary
    @sum = Summary.new
    @sum.summarize(deals)
    # get the basic simulated summary 
    @sim = Simulation.new
    @sim.simulate(deals, 'dist', 'given', nil, 1.0, nil, nil, nil)
  end
  
  # rep by rep summary of deals
  def summarize_all_reps
    summarize_by(Rep)
    @source = "rep"
    @page_title = "Analytics > Summarize reps"
    render "summarize_by"
  end
  
  #region by region summary of deals
  def summarize_all_regions
    summarize_by(Region)
    @source = "region"
    @page_title = "Analytics > Summarize regions"
    render "summarize_by"
  end
  
  def summarize_by(source)
    # source is Rep or Region
    # iterate source creating a summary object for the deals of each 
    # when complete, @source_all will be either Rep.all or Region.all
    # and @summary_all will contain each of the (rep or region) summaries   
    @summaries = Array.new
    @sources = source.all
    @sources.each do |s|
      sum = Summary.new
      sum.summarize(filtered_deals("", "all", s.deals))
      @summaries << sum
    end    
  end
  
  # summarize the deals for the rep given by params[:id]
  def summarize_this_rep
    rep = Rep.find(params[:id])
    @deals = filtered_deals("", "all", rep.deals)
    summarize_all(@deals)
    @sum.predicted = rep.amount_predicted_regression(:forecast_and_pipeline)[:value]
    @show_predicted = true
    @page_title = "Analytics > Summarize rep"
    flash.now[:notice] = "Summary for rep " + rep.name
    render "summarize_deals"
  end  
  
  # summarize the deals for the region given by params[:id]
  def summarize_this_region
    region = Region.find(params[:id])
    @deals = filtered_deals("", "all", region.deals)
    summarize_all(@deals)
    @sum.predicted = region.amount_predicted_regression
    @show_predicted = true
    @page_title = "Analytics > Summarize region"
    flash.now[:notice] = "Summary for region " + region.name
    render "summarize_deals"
  end
  
  #
  # methods for simulations
  #     
  
  # get parameters for the simulation
  def simulate_parameters
    @reps = Rep.all
    @regions = Region.all
    @page_title = "Analytics > Simulation parameters"
  end
  
  # simulates the deals 
  def simulate_deals 
    
    # set up the simulation parameters
    
    if params[:deal_scope] == 'rep'   
      @deals = Rep.find(params[:rep_scope][:rep_id]).deals
    elsif params[:deal_scope] == 'region'
      @deals = Region.find(params[:region_scope][:region_id]).deals
    else
      @deals = Deal.all
    end
    
    factor = case params[:deal_probability]
             when "set" 
               params[:set_probability].to_f
             when "scaled" 
               params[:scaled_probability].to_f
             else 
               nil
             end
    
    objective = params[:deal_objective]                 
    mode = params[:deal_probability]
    target = params[:target_forecast] == "" ? nil : params[:target_forecast].to_f
    min = params[:min_forecast] == "" ? nil : params[:min_forecast].to_f
    max = params[:max_forecast] == "" ? nil : params[:max_forecast].to_f
    value = params[:scale_values] == "" ? 1.0 : params[:scale_values].to_f
    
    # do the simulation
    @sim = Simulation.new    
    @sim.simulate(filtered_deals(params[:limit_probability], params[:forecast_scope], @deals), objective, mode, factor, value, target, min, max)

    # prepare the charts
    
    if @sim.status == "ok" 
   		# prepare the probability functions url string for google charts from simulation data
    	vis = Visualization.new
    	vis.set_title("Deal statistics with " + @sim.selected_count.to_s + " of " + @deals.length.to_s + " deals selected")
    	vis.make_probability_functions_chart(@sim.pdf, @sim.cdf, @sim.mean)
    	@pf_vis = vis.get_url
      flash.now[:notice] = "Simulation finished: " + @sim.selected_count.to_s + " deals, " + @sim.iterations.to_s + " samples in " + @sim.elapsed_time.to_s + " msecs"
	  else
	    flash.now[:notice] = "Simulation aborted - please check parameters"
    end
  	
    @page_title = "Analytics > Simulate deals"
  end
  
  # charts the pdf and cdf functions 
  def chart_pdf_cdf
   	@page_title = "Analytics > Simulated probability functions"
  	@pf_vis = params[:vis]
  end
  
  #
  # methods for the direct charts
  #
  
  # charts the most likely values in histogram format
  def chart_likely_histo
    @page_title = "Analytics > Most likely values"
    @mlv_histo_vis = Visualization.new.make_most_likely_chart_histo(Deal.all)
  end

  # charts the win probabilities in histogram format  
  def chart_prob_histo
    @page_title = "Analytics > Stages/win probabilities"
    @p_histo_vis = Visualization.new.make_prob_chart_histo(Deal.all)
  end
  
  # charts the achieved results vs. 'x' either the forecasts or the pipelines
  def chart_achieved_vs_x 
    @filter_avx_by = params[:filter_avx_by]
    @avx_type = params[:avx_type]
    
    # make the filtered histories array according to the parameter
    case @filter_avx_by
    when "show_region"
      # use all rep histories for the given region
      filtered_histories = Array.new
      if params[:region_select][:id] != ""
        @selected_region = Region.find(params[:region_select][:id])
      else
        # defaults to first region is show_region is clicked 
        # but a region is not selected
        @selected_region = Region.first
        flash.now[:notice] = "You did not select a region, so used 'first' region. Please select a region."
      end
      @selected_region.reps.each do |rep|
        rep.histories.each do |history|
          filtered_histories << history
        end
      end
      @scope = "region: " + @selected_region.name
    when "show_rep"
      # use all histories for the given rep
      if params[:rep_select][:id] != ""
        @selected_rep = Rep.find(params[:rep_select][:id])
      else
        # defaults to first rep is show_region is clicked 
        # but a rep is not selected
        @selected_rep = Rep.first
        flash.now[:notice] = "You did not select a rep, so used 'first' rep. Please select a rep."
      end      
      filtered_histories = @selected_rep.histories.all
      @scope = "rep: " + @selected_rep.name
    else
      # default: use all histories
      filtered_histories = History.all
      @scope = "all"
    end
    
    # @filter_avx_by = "show_all"   # reset to keep the filter select clean

    # make the achieved and forecasts arrays and pass to visualization method
    # aggregate_histories parameter set in view check box
    @aggregate_histories_checked = (params[:aggregate_histories] == "1") ? true : false   # used in the view
    if @aggregate_histories_checked 
      # aggregate 
      ax_hash = aggregate_histories(filtered_histories)
      a = ax_hash[:achieveds]
      x = @avx_type == 'forecast' ? ax_hash[:forecasts] : ax_hash[:pipelines]
    else
      # don't aggregate
      a = filtered_histories.collect{ |history| history.amount_achieved }
      x = @avx_type == 'forecast' ? filtered_histories.collect{ |history| history.amount_forecast } : filtered_histories.collect{ |history| history.amount_pipeline }
    end

    avx = Visualization.new
    avx.set_title("Achieved Results vs. " + @avx_type.humanize + "($1,000s)")
    if @avx_type == 'forecast'
      @avx_vis = avx.make_chart_achieved_vs_x(a, x, 'Forecast', 1.0)
    else
      @avx_vis = avx.make_chart_achieved_vs_x(a, x, 'Pipeline', 2.5)
    end  
        
    # for use in the view filter selects
    @reps = Rep.all
    @regions = Region.all

    # get the linear regression theta (angle to 45-degree true forecast line)
    # note: must have more than one data point for this
    if a.length > 1
      r = Regression.new
      r.lr(x.collect { |e| [e] }, a, true)
      @theta = (@avx_type == 'forecast' ? r.theta_m_degrees(1.0).round : r.theta_m_degrees(0.4).round)
    else
      @theta = nil
    end
    
    @page_title = "Analytics > Achieved results vs. " + params[:avx_type]
  end
  
  
  # aggregates the given histories by rep
  # e.g., returns a new array with entries for each rep that sums that rep's achieveds and forecasts
  # can't assume the given histories array is sorted in any order
  def aggregate_histories(histories)
    # sort histories by rep_id (ascending or descending does not matter)
    sorted = histories.length.times.collect{ |i| [histories[i].rep_id, i] }.sort!
    sorted_histories = sorted.length.times.collect{ |i| histories[sorted[i][1]] }
    
    # aggregate the values by processing the histories in the sort order
    a = Array.new
    f = Array.new
    p = Array.new
    a_sum = f_sum = p_sum = 0.0
    current_rep_id = sorted_histories[0].rep_id
    sorted_histories.each do |history|
      if history.rep_id == current_rep_id
        # still on current rep
        a_sum += history.amount_achieved
        f_sum += history.amount_forecast
        p_sum += history.amount_pipeline
      else
        # encountered a new rep; finish up the previous rep and start the new
        a << a_sum
        f << f_sum
        p << p_sum
        a_sum = history.amount_achieved
        f_sum = history.amount_forecast
        p_sum = history.amount_pipeline
        current_rep_id = history.rep_id
      end
    end
    
    # finish up the last rep and return the hash
    a << a_sum
    f << f_sum
    p << p_sum            
    { :achieveds => a, :forecasts => f, :pipelines => p }  # return the aggregated achieved and forecasts in a hash
  end
    
  
  # private methods ######################
  
  # returns array of deals that meet the forecast and probability limit filters
  def filtered_deals(limit, forecast, input_deals)
    
    # convert limit for local use
    if limit == "" 
      l = 0.0
    else
      l = limit.to_f
      if l < 0.0 then l = 0.0 end
      if l > 1.0 then l = 1.0 end
    end
        
    # convert forecast for local use
    f = forecast == "forecast" ? true : false
    
    filtered_deals = Array.new
    input_deals.each do |deal|
      # deals that pass the filters are added to the array
      if (f ? deal.is_forecast : true) && (deal.probability >= l) then filtered_deals << deal end
    end

    filtered_deals
    
  end
  
end
