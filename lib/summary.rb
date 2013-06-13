# Copyright © by David M. Spenhoff. All rights reserved

class Summary

	def initialize 
	end
	
	# summarizes the selected deals (might be all deals or the deals for a rep or a region)
	def summarize(deals)
	  
	  @num_deals = deals.length
	  @num_forecast = @num_pipeline = 0
	  
  	# calculate sums of interest
  	@selected_count = 0
  	@mode = @f_mode = 0
  	@min = @f_min = 0
  	@max = @f_max = 0
  	@mean = @f_mean = 0
  	@forecast = @f_forecast = 0.0
  	@pipeline = @f_pipeline = 0.0
  	@all_open = @f_all_open = 0.0

  	deals.each do |deal|
	  	@selected_count += 1
	  	
  	  @all_open += deal.most_likely_value
  	  @f_all_open += deal.most_likely_value * deal.probability
	  	
	  	if deal.is_forecast 
	  	  @num_forecast += 1
	  	  @forecast += deal.most_likely_value
	  	  @f_forecast += deal.most_likely_value * deal.probability
	  	end
	  	
	  	if deal.is_pipeline 
	  	  @num_pipeline += 1
	  	  @pipeline += deal.most_likely_value
	  	  @f_pipeline += deal.most_likely_value * deal.probability
	  	end
	  		
	  	@mode += deal.most_likely_value
	  	@f_mode += deal.most_likely_value * deal.probability
	  		
	  	@min += deal.minimum_value
	  	@f_min += deal.minimum_value * deal.probability
	  		
	 		@max += deal.maximum_value
	 		@f_max += deal.maximum_value * deal.probability
	 			
 			@mean += (deal.minimum_value + deal.most_likely_value + deal.maximum_value).to_f / 3.0
 			@f_mean += (deal.minimum_value + deal.most_likely_value + deal.maximum_value).to_f / 3.0 * deal.probability	 
 			
 			@coverage = @pipeline / @forecast
      @f_coverage = @f_pipeline / @f_forecast
      
      @predicted = nil  # set externally, should fix that
      		
  	end
  	
  end

	# lots of data points are summarized and can be read
	attr_reader :num_deals, :selected_count, :all_open, :f_all_open
	attr_reader :num_forecast, :forecast, :f_forecast, :num_pipeline, :pipeline, :f_pipeline
	attr_reader :mean, :f_mean, :mode, :f_mode, :min, :f_min, :max, :f_max, :coverage, :f_coverage
	
	# this one is set externally
	# bad design, should fix it
	# however, when used it is convenient to put predicted in with forecast, etc, in the summary
	attr_accessor :predicted
  # 
end