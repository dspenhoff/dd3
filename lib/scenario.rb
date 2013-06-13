# Copyright © by David M. Spenhoff. All rights reserved

# generates a new scenario of regions, reps, deals and histories

class Scenario
  
  def initialize
    # set up some static data
    @sfdc_stages = sfdc_stages
    @epochs = make_epochs
  end
  
  # creates a new scenario
  def create(num_regions, num_reps, num_deals, num_histories, over, under) 
    make_regions(num_regions)
    make_reps(num_reps)
    make_deals(num_deals)
    make_forecasts 
    make_histories(num_histories, over, under) 
  end
  
  # creates a new 'deep' scenario encompassing multiple time periods
  # note: num_periods is the number of time periods the scenario is to cover
  # num_histories is the number of past periods the histories are to cover
  # thus, num_histories <= num_periods
  # in general, num_periods should a couple of periods greater than num_histories
  # so the scenario (deal) evolution can settle down
  def create_deep(num_periods, num_regions, num_reps, num_deals, num_histories, over, under)
    puts "+++++ creating deep scenario"
    make_regions(num_regions)
    make_reps(num_reps)
    make_deep_deals(num_deals, num_periods)
    make_deep_histories(num_histories, over, under)
  end
  
  #
  # private methods
  #
  
  private
  
  #
  # regions
  #
  
  # creates new regions, first deleting any current records
  def make_regions(num_regions) 
    @regions = Array.new
    num_regions.times do |i|
      region = Region.new
      region.name = "Region_" + (i + 1).to_s      
      @regions << region
    end 
    # delete current records and save new
    delete_current_records(Region.all)
    save_new_records(@regions)
  end
  
  #
  # reps
  #
  
  # creates new reps, first deleting any current records 
  def make_reps(num_reps) 
    # can't have more regions than reps (so every region can have at least one rep)
    if num_reps < @regions.length then num_reps = @regions.length end
    
    @reps = Array.new
    num_reps.times do |i|
      rep = Rep.new  
      rep.name = "Rep_" + (i + 1).to_s
      # set the (random) region_id from @regions (@regions must be previously generated)
      # make sure each region has at least one rep assigned
      rep.region_id = i < @regions.length ? @regions[i].id : @regions[(rand(0) * @regions.length).floor].id
      @reps << rep
    end
    # delete current records and save new
    delete_current_records(Rep.all)
    save_new_records(@reps)
  end
  
  #
  # deals
  #
  
  # creates a single epoch deal scenario
  def make_deals(num_deals)        
    # want at least one deal per rep
    if num_deals < @reps.length then num_deals = @reps.length end 
    
    @deals = Array.new
  	num_deals.times do |i|
  	  # make a deal for the current '0' epoch
  	  @deals << make_a_deal((i + 1).to_s, @epochs[0])
  	end
  	
  	# make the pipeline
  	make_pipeline 
  	
  	# delete current records and save new
    delete_current_records(Deal.all)
    save_new_records(@deals)
  end 
  
  # creates a 'deep' (multi period) set of deals
  # the method is to create an initial deal set at an early epoch
  # and evolve the deal set up to the current epoch
  def make_deep_deals(num_deals, num_periods)
    @deals = Array.new
    
    num_periods.times do |j|
      # for each period evolve deep deals then add new deals
      epoch_index = num_periods - j - 1   # start with the earliest epoch
      num_deals.times do |i|    
        @new_deal = make_a_deal((j + 1).to_s + "_" + (i + 1).to_s, @epochs[epoch_index])
        evolve_deal(epoch_index)
        @deals << @new_deal
      end
    end
    
  	# make the pipeline
  	make_pipeline 
  	# delete current records and save new
    delete_current_records(Deal.all)
    save_new_records(@deals)  
  end
  
  def evolve_deal(epoch_index)
    # if epoch index == 0, i.e., it's the 'terminal' epoch, then
    # this iteration will not execute and the deal will be returned as given
    
    epoch_index.times do |j|
      # transition from epoch k = (epoch_index - j) to k = (epoch_index - j - 1)
      k = epoch_index - j
      if @new_deal.stage_name != "Closed Won" && @new_deal.stage_name != "Closed Lost"
        # deal is still open
        if @new_deal.probability >= 0.5
          # deal is pipeline
          if rand(0) < @new_deal.probability
            # deal is "won"
            @new_deal.stage_name = "Closed Won"
            @new_deal.probability = sfdc_stage_probability(@new_deal.stage_name)
            @new_deal.actual_close_date = @new_deal.expected_close_date
            break
          elsif rand(0) < 0.5
            # deal is lost
            @new_deal.stage_name = "Closed Lost"
            @new_deal.probability = sfdc_stage_probability(@new_deal.stage_name)
            @new_deal.actual_close_date = @new_deal.expected_close_date
            break           
          else
            # deal advances to next period
            advance_deal(k)
          end
        else
          #deal is not pipeline
          if rand(0) < 0.5
            # deal is lost
            @new_deal.stage_name = "Closed Lost"
            @new_deal.probability = sfdc_stage_probability(@new_deal.stage_name)
            @new_deal.actual_close_date = @new_deal.expected_close_date
            break   
          else
            # deal advances to next period
            advance_deal(k)
          end                    
        end
      end
    end

    @new_deal
    
  end
  
  # the given deal is kept open and is advanced to the 'next' period 
  # k indexes the epochs array, so advancing means lreducing k
  def advance_deal(k)
    
    # get the current epoch end date (close_date)
    # move it to next epoch end 
    # 50/50 the deal advances stage, but does not pass negotiate (90%)
    
    @new_deal.expected_close_date = @epochs[k - 1][:end]
    
    if rand(0) < 0.5
      # stage advances (else stays the same)
      @sfdc_stages.length do |i|
        if deal.stage_name == @sfdc_stages[i][:stage]
          if i == 0
            i = 2
          elsif i < 7
            i += 1
          end
        end
        @new_deal.stage_name = @sfdc_stages[i][:stage]
        @new_deal.propbability = @sfdc_stages[i][:probability]
      end
    end
  
  end
  
  # makes a deal for the given eopch
  def make_a_deal(suffix, epoch)
    deal = Deal.new
    deal.name = "Deal_" + suffix

	  # calc the win probability
	  u = rand(0)
	  if u < 0.15
      stage_index = 0 # prospect
	  elsif u < 0.4
      stage_index = 2 # needs
	  elsif u < 0.55
      stage_index = 3 # value prop
	  elsif u < 0.70
      stage_index = 4 # know deciders
	  elsif u < 0.85
      stage_index = 5 # perception
	  elsif u < 0.95
      stage_index = 6 # quote
	  else
      stage_index = 7 # negotiate
	  end	
	  
	  deal.stage_name = @sfdc_stages[stage_index][:stage]
	  deal.probability = @sfdc_stages[stage_index][:probability] / 100.0   

	  # calc the most likely deal value
	  u = rand(0)
	  if u < 0.4
	    mlv = 10 + rand(0) * 40	        
	  elsif u < 0.8
	    mlv = 50 + rand(0) * 150	        
	  elsif u < 0.99
	    mlv = 210 + rand(0) * 300	        	    
	  else
	    mlv = 520 + rand(0) * 500	        	    
	  end
	  deal.most_likely_value = mlv.to_i * 1000

	  # calc the min deal value
	  mnv =  rand(0) < 0.5 ? mlv - rand(0) * mlv * 0.40 : mlv - rand(0) * mlv * 0.20
	  deal.minimum_value = mnv.to_i * 1000

	  # calc the max deal value
	  mxv =  rand(0) < 0.5 ? mlv + rand(0) * mlv * 0.40 : mlv + rand(0) * mlv * 0.20
	  deal.maximum_value = mxv.to_i * 1000	 

    # set the (random) rep_id from @reps (@reps must be previously generated)
    # make sure each rep has at least one deal assigned
    deal.rep_id = @deals.length <= @reps.length ? @reps[@deals.length - 1].id : @reps[(rand(0) * @reps.length).floor].id
      
    # set the dates from the given epoch
	  deal.open_date = epoch[:start]
	  deal.expected_close_date = epoch[:end]
	  deal.actual_close_date = epoch[:end]
    deal  # return the deal
  end
  
  #
  # histories
  #
  
  # creates a set of rep histories from the 'deep deals' set
  # - for each period it is open including period it closes deal value is added to rep's pipeline
  # - for period it closes deal value is added to rep's achieved (if won)
  # - ie, all open deals are pipeline
  # - no explicit idea about the rep's forecast
  # - no tracking deal value, ie, the final deal 
  def make_deep_histories(num_histories, over, under)
    puts "+++++ start histories"
    # set up the rep histories - zero the values to accumulate sums
    @histories = Array.new
    @reps.each do |rep|
      for i in 0...num_histories  
        history = History.new
        history.rep_id = rep.id
        history.date = @epochs[i + 1][:end] # skips the '0' epoch (current time)
        history.amount_pipeline = history.amount_achieved = history.amount_forecast = 0.0
        history.deals_pipeline = history.deals_achieved = history.deals_forecast = 0.0
        @histories << history
      end     
    end
    
    # step through the deals and accumulate values to rep histories    
    @deals.each do |deal|
      # get the rep and epochs
      rep_i = reps_index(deal.rep_id)
      open_i = epochs_start_index(deal.open_date)
      close_i = epochs_end_index(deal.expected_close_date)
      open_periods = close_i - open_i
      for i in open_i...close_i
        # accumulate values for 'open' periods
        accumulate_history(deal, which_history(rep_i, i))
      end
      #accumulate values for 'close' period
      accumulate_history(deal, which_history(rep_i, close_i))
    end
    
  	# delete current records and save new
    delete_current_records(History.all)
    save_new_records(@histories)
  end
  
  # accumulates values for the given deal in the given history
  def accumulate_history(deal, history)
    history.amount_pipeline += deal.most_likely_value
    history.deals_pipeline += 1
    history.amount_forecast += deal.most_likely_value
    history.deals_forecast += 1
    if deal.stage_name == "Closed Won"
      history.amount_achieved += deal.most_likely_value
      history.deals_achieved += 1
    end
  end
  
  # creates num_histories histories for each rep
  def make_histories(num_histories, over, under)
    # can't have more histories than epochs 
    if num_histories > @epochs.length then num_histories = @epochs.length end  
    
    @histories = Array.new 
     
    @reps.each do |rep|
      # set rep achievement profile (under/over achiever, etc.)
      u = rand(0)
      @num_over = @num_under = @num_neutral = 0
      if u < over
        achievement_profile = :over_achiever
      elsif u < over + under
        achievement_profile = :under_achiever
      else
        achievement_profile = :neutral_achiever
      end
      
      num_histories.times do |i|
        # initialize the history
        history = History.new
        history.rep_id = rep.id
        history.date = @epochs[i][:end]
        
        # calculate the rep forecast factor for this epoch (epoch[i])
        # over achiever understates forecast by 10%-20% and thus over achieves the forecast
        # under achiever overstates the forecast by 20%-40% and thus under achieves the forecast
        # neutral achiever forecasts +/- 10%
        if achievement_profile == :over_achiever
          forecast_factor = 0.9 - rand(0) * 0.1
        elsif achievement_profile == :under_achiever
          forecast_factor = 1.2 + rand(0) * 0.2
        else
          forecast_factor = 0.9 + rand(0) * 0.2
        end

        # pick a subset of deals and simulate it to get the achieved values
        # initially, just use rep.deals as the base and randomize off it
        # also initially assume pipeline deals and forecast deals are identical
        # use most_likely estimate as the deal value        

        # calc the number of deals to generate
        n = rep.deals.length * (0.8 + rand(0) * 0.4)
      
        # pick 'n' deals from the set of all deals
        p = n / @deals.length
        rep_deals = Array.new
        @deals.each do |deal|
          if rand(0) < p
            rep_deals << deal
          end
        end

        # determine amount pipeline, forecast, achieved based on 'won' deals
        # note forecast amount is total of factored most likely value for deals with p >= 0.6
        history.deals_achieved = history.deals_forecast = history.deals_pipeline = 0
        history.amount_pipeline = history.amount_forecast = history.amount_achieved = 0.0
        rep_deals.each do |deal|
          if deal.probability >= 0.5  # deal is pipeline if p >= 0.5 
            history.deals_pipeline += 1 
            history.amount_pipeline += deal.most_likely_value 
            if deal.probability < rand(0)   # deal is 'won' i.e. achieved
              history.deals_achieved += 1
              history.amount_achieved += deal.most_likely_value              
            end
          end
          if deal.probability > 0.6    # deal is forecast if p >= 0.6
            history.deals_forecast += 1
            history.amount_forecast += deal.probability * deal.most_likely_value 
          end
        end
        
        # adjust amount forecast as needed
        history.amount_forecast *= forecast_factor
        if history.amount_forecast > history.amount_pipeline then history.amount_forecast = history.amount_pipeline end
        if history.amount_forecast < 0.1 * history.amount_pipeline then history.amount_forecast = 0.1 * history.amount_pipeline end
          
        # assume all deals start open and are closed .... either won or lost
        history.num_open_deals = rep_deals.length
        history.num_closed_won = history.deals_achieved
        history.num_closed_lost = rep_deals.length - history.num_closed_won
        
        @histories << history
      end
    end
    # delete current records and save new
    delete_current_records(History.all)
    save_new_records(@histories)
  end
  
  # creates a current pipeline of deals
  def make_pipeline
    @deals.each do |deal|
      deal.is_pipeline = deal.deal_is_pipeline
      deal.is_forecast = deal.deal_is_forecast
    end
  end
  
  # creates the forecast value for each rep
  def make_forecasts
    reps = Rep.all
    reps.each do |rep|
      rep.forecast = 0.0
      deals = rep.deals
      deals.each do |deal|
        if deal.probability >= 0.6 then rep.forecast += deal.probability * deal.most_likely_value end
      end
      rep.save
    end
  end
  
  #
  # some utility methods
  #
  
  #sets up the epochs (historical time periods)
  def make_epochs
    epochs = Array.new
    epochs << {:start => Time.utc(2012, "jan", 1, 0, 0, 0), :end => Time.utc(2012, "mar", 31, 0, 0, 0), :name => "2012 Q1"}
    epochs << {:start => Time.utc(2011, "oct", 1, 0, 0, 0), :end => Time.utc(2011, "dec", 31, 0, 0, 0), :name => "2011 Q4"}
    epochs << {:start => Time.utc(2011, "jul", 1, 0, 0, 0), :end => Time.utc(2011, "sep", 30, 0, 0, 0), :name => "2011 Q3"}
    epochs << {:start => Time.utc(2011, "apr", 1, 0, 0, 0), :end => Time.utc(2011, "jun", 30, 0, 0, 0), :name => "2011 Q2"}
    epochs << {:start => Time.utc(2011, "jan", 1, 0, 0, 0), :end => Time.utc(2011, "mar", 31, 0, 0, 0), :name => "2011 Q1"}
    epochs << {:start => Time.utc(2010, "oct", 1, 0, 0, 0), :end => Time.utc(2010, "dec", 31, 0, 0, 0), :name => "2010 Q4"}
    epochs << {:start => Time.utc(2010, "jul", 1, 0, 0, 0), :end => Time.utc(2010, "sep", 30, 0, 0, 0), :name => "2010 Q3"}
    epochs << {:start => Time.utc(2010, "apr", 1, 0, 0, 0), :end => Time.utc(2010, "jun", 30, 0, 0, 0), :name => "2010 Q2"}
    epochs << {:start => Time.utc(2010, "jan", 1, 0, 0, 0), :end => Time.utc(2010, "mar", 31, 0, 0, 0), :name => "2010 Q1"}
  end
  
  # returns the index into the epochs array corresponding to the given (:end) date
  def epochs_end_index(date)
    index = 0
    @epochs.length.times do |i|
      if @epochs[i][:end] == date
        index = i 
        break
      end
    end
    index
  end
    
  # returns the index into the epochs array corresponding to the given (:start) date
  def epochs_start_index(date)
    index = 0
    @epochs.length.times do |i|
      if @epochs[i][:start] == date
        index = i 
        break
      end
    end
    index
  end
  
  # returns the index into the reps array corresponding to the given rep id
  def reps_index(id)
    index = 0
    @reps.length.times do |i|
      if @reps[i].id == id
        index = i
        break
      end
    end
    index
  end
  
  # returns the @histories array element associated with the given rep and epoch (indexes)
  def which_history(rep_index, epoch_index)
    history = @histories[0]
    @histories.each do |h|
      if h.rep_id == @reps[rep_index].id
        if h.date == @epochs[epoch_index][:end]
          history = h
          break
        end
      end
    end
    history   # return value
  end
  
  #
  # utility methods to delete and save the regions, reps, deals and histories
  # i.e., any collection of records
  #
  
  # deletes all current records for the given collection of records
  # (e.g., Region.all, Rep.all. Deal.all, History.all)
  def delete_current_records(collection)
    collection.each do |record|
      record.destroy
    end
  end

  # saves the new collection of records  
  # (e.g., @regions, @reps, @deals, @histories)
  def save_new_records(collection)
    collection.each do |record|
      record.save
    end
  end 

end