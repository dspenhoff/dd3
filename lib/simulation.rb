# Copyright © by David M. Spenhoff. All rights reserved

require "stats"				# pdf and cdf

class Simulation

	def initialize
	end
	
  def simulate(deals, objective_mode, probability_mode, factor, value_multiplier, target, min, max)
    
		start_time = Time.now.to_f		# time the iteration loop

  	# create pdf and set its min/max range values
    # create several local array instances and pre-claculated data to speed up the inner loop
    # in general, this code is written for performance, not for good coding practice :-)

  	ratio = Array.new   
  	prod1 = Array.new
  	prod2 = Array.new
    p = Array.new
    mean = Array.new
    minimum_value = Array.new
    maximum_value = Array.new
    most_likely_value = Array.new
    history_adjustment = Array.new
  	@selected_count = sum_min = sum_max = sim_count = 0
  	deals.each do |deal|
  		@selected_count += 1
  		max_min_diff = deal.maximum_value - deal.minimum_value
    	mode_min_diff = deal.most_likely_value - deal.minimum_value
  		ratio << mode_min_diff.to_f / max_min_diff
  		prod1 << (deal.maximum_value - deal.minimum_value).to_f * mode_min_diff
      prod2 << max_min_diff.to_f * (deal.maximum_value - deal.most_likely_value)
      
      # get the deal win probability applying factors as necessary
      # note: regardless, p <= 1.0
      if probability_mode == "given"
        q = deal.probability
      elsif probability_mode == "set"
        q = factor
      elsif probability_mode =="scaled"
        q = factor * deal.probability
      elsif probability_mode == "accuracy"
        ## adjust the prob for the deal rep's historical accuracy 
        q = deal.probability * deal.rep.forecast_accuracy
      elsif probability_mode == "predict"
        ## adjust the prob for the deal rep's predicted achievement (based on forecast history)
        q = deal.probability * deal.rep.predicted_accuracy(:forecast_and_pipeline) 
      else
        # default (should not happen)
        q << deal.probability
      end
      p << (q < 1.0 ? q : 1.0)
      
      minimum_value << deal.minimum_value * value_multiplier
      maximum_value << deal.maximum_value * value_multiplier
      most_likely_value << deal.most_likely_value * value_multiplier
      mean << (deal.minimum_value + deal.most_likely_value + deal.maximum_value) * value_multiplier / 3
      #history_adjustment << deal.rep.pipeline_accuracy
  	end
  	#@sim_selected_count = selected_deals.length
  	if @selected_count == 0  
  	  @status = "abort"
  	  return
    end    
    @status = "ok"
  	  
  	# convert min and max parameters to a range
  	if min == nil || max == nil 
  	  range = nil
  	else
  	  range = 0 # not nil
  	  range_min = min == nil ? 0 : min.to_f
  	  range_max = max == nil ? 999999999 : max.to_f
  	end

  	# outer loop, control the sampling and data collection
  	@samples = Array.new
  	@min = 99999999
  	@max = 0
  	@mean = 0.0
  	@p_le_target = target == nil ? nil : 0 
  	@p_le_max = max == nil ? nil : 0
  	@p_ge_min = min == nil ? nil : 0
  	@p_range = range == nil ? nil : 0
  	@iterations = 1000
  	@iterations.times do |i|
  		# inner loop, iterate over the activities to generate a sample
  		sum_sample_value = 0
  		@selected_count.times do |k|
        #d = selected_deals[k]
  		  # samples whether deal is 'won' and if so samples and sums the value
  		  if rand(0) < p[k]
          if objective_mode == "dist"
            # the triangle rng is stripped bare and inlined for speed (using the pre-calcs)
            u = rand(0)
            if u < ratio[k]
              sample_value = minimum_value[k] + Math.sqrt(u * prod1[k])
            else 
              sample_value = maximum_value[k] - Math.sqrt((1 - u) * prod2[k])
            end
          elsif objective_mode == "min"
            sample_value = minimum_value[k]
          elsif objective_mode == "mode"
            sample_value = most_likely_value[k]
          elsif objective_mode == "max"
            sample_value = maximum_value[k]
          elsif objective_mode == "mean" 
            # defaults to mean value
            sample_value = mean[k]
          end
          sum_sample_value += sample_value
        end
  		end
  		
  		@samples << sum_sample_value 

  	end
      	
  	# process the samples array into pdf, cdf and sample statistics
  	# puts @samples
  	@samples.sort!
    @min = @samples[0]
    @max = @samples[@iterations - 1]
  	@pdf = Pdf.new
  	@pdf.min_range= @min - 100
  	@pdf.max_range= @max + 100
  	@samples.each do |sample|
  	  @pdf.update(sample)  	  
  	  @mean += sample  	  
  	  if @p_le_target != nil
  		  if sample <= target then @p_le_target += 1 end
  		end  		
  		if @p_le_max != nil
  		  if sample <= max then @p_le_max += 1 end
  		end
  		if @p_ge_min != nil
  		  if sample >= min then @p_ge_min += 1 end
  		end  		
  		if @p_range != nil
  		  if (range_min <= sample && sample <= range_max) then @p_range += 1 end
 		  end
  	end
  	@pdf.normalize(@iterations)
  	
  	# create cdf from the pdf
  	@cdf = Cdf.new
		@cdf.from_pdf(@pdf)
				
  	# normalize the mean to the number of samples (iterations)
  	@mean /= @iterations

  	#calculate statistics of interest
  	@standard_deviation = 0
  	@samples.each do |sample|
  	  @standard_deviation += (sample - @mean) ** 2
  	end
  	@standard_deviation = Math.sqrt(@standard_deviation / (@iterations - 1))  	
		@cdf_mean = @cdf.F(@mean)
  	@mode = @pdf.mode
  	@median = @cdf.median
  	@p_60 = @cdf.F_inverse(0.4)
  	@p_70 = @cdf.F_inverse(0.3)
  	@p_80 = @cdf.F_inverse(0.2)
  	@p_90 = @cdf.F_inverse(0.1)
   	@p_le_target = @p_le_target == nil ? nil : @p_le_target.to_f / @iterations
    @p_range = @p_range == nil ? nil : @p_range.to_f / @iterations
    @p_ge_min = @p_ge_min == nil ? nil : @p_ge_min.to_f / @iterations   
    @p_le_max = @p_le_max == nil ? nil : @p_le_max.to_f / @iterations   
  	
  	@elapsed_time = ((Time.now.to_f - start_time) * 10000).to_i / 10.0
  end
  
  # produces lots of data points
  attr_reader :status, :pdf, :cdf, :iterations, :selected_count, :min, :max, :mean, :standard_deviation
  attr_reader :cdf_mean, :mode, :median, :p_60, :p_70, :p_80, :p_90
  attr_reader :p_le_target, :p_range, :p_ge_min, :p_le_max
  attr_reader :elapsed_time
    
  private
  
  # calculates a random sample from a triangular distribution defined by the triple (min, peak, max)
	# the triangular distribution is used to model continuous random varibles that have min, max and most likely values 
  def rand_triangular_dist(r, p, q, min, max)
    # stripped down to bare metal for speed
    # r, p, q are pre-calculated from the distribution parameters
		u = rand(0)
		(u < r) ? min + Math.sqrt(u * p) : max - Math.sqrt((1 - u) * q)
  end

end