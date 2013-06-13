class Region < ActiveRecord::Base
  has_many :reps
  has_many :deals, :through => :reps
  validates_presence_of :name, :allow_nil => false, :allow_blank => false, :message => "Must have a name"  

  #
  # class methods
  #
 
  # returns the current open deals for region's reps
  def open_deals
    sum = 0.0
    self.reps.each do |rep|
      sum += rep.open_deals
    end
    sum
  end
  
  # returns the current forecast for region's reps
  def current_forecast
    sum = 0.0
    self.reps.each do |rep|
      sum += rep.current_forecast
    end
    sum
  end
  
  # returns the pipeline (all deals) for the region
  def current_pipeline
      sum = 0.0
      self.deals.each do |deal|
        if deal.is_pipeline then sum += deal.most_likely_value end
      end
      sum
    end    
  
  # returns the number of reps in the region
  def num_reps
    self.reps.length
  end
  
  # returns the total number of deals in the region
  def num_deals
    sum = 0
    self.reps.each do |rep|
      sum += rep.num_deals
    end
    sum
  end
  
  # returns the number of deals in the region's current forecast
  def num_forecast
    sum = 0
    self.reps.each do |rep|
      sum += rep.num_forecast
    end
    sum
  end
  
  # returns the number of deals in the region's current pipeline
  def num_pipeline
    sum = 0
    self.reps.each do |rep|
      sum += rep.num_pipeline
    end
    sum
  end  
  
  # returns the region forecast accuracy aggregated over rep histories
  # note must multiply by 100 to convert to percentage
  def forecast_accuracy
    sum_a = sum_f = 0.0
    self.reps.each do |rep|
      rep.histories.each do |history|
        sum_a += history.amount_achieved
        sum_f += history.amount_forecast
      end
    end
    sum_f > 0.0 ? sum_a / sum_f : 0.0
  end
  
  # returns the predicted achieved amount based on the current forecast and the historical forecast accuracy
  def amount_predicted_average
    self.current_forecast * self.forecast_accuracy
  end
  
  # this version sums the regression predictions for the reps in the region
  # TODO - calculate a new regression based on aggregated historical data across reps
  #        e.g., plow through all the reps and histories to generate the aggregate x, y input to the regression
  def amount_predicted_regression
    sum = 0.0
    self.reps.each do |rep|
      sum += rep.amount_predicted_regression(:forecast_and_pipeline)[:value]
    end
    sum
  end
 
  # returns the region's current forecast coverage (i.e., the aggregate coverage for its reps)
  # note must multiply by 100 to convert to percentage
  # note: this is replicated code from the Rep.total_rep_forecast_coverage method,
  # which is probably poor design but I don't know better
  def current_forecast_coverage
    sum_f = sum_p = 0.0
    self.reps.each do |rep|
      sum_f += rep.current_forecast
      sum_p += rep.current_pipeline
    end
    sum_f > 0 ? sum_p / sum_f : 0.0
  end
  
  # returns the historical forecast coverage for the region, aggregated over the region's reps/histories
  # see caveats above
  def forecast_coverage
    sum_f = sum_p = 0.0
    self.reps.each do |rep|
      rep.histories.each do |history|
        sum_f += history.amount_forecast
        sum_p += history.amount_pipeline
      end
    end
    sum_f > 0 ? sum_p / sum_f : 0.0
  end 
  
  # returns the historical achieved coverage for the region, aggregated over the region's reps/histories
  # see caveats above
  def achieved_coverage
    sum_a = sum_p = 0.0
    self.reps.each do |rep|
      rep.histories.each do |history|
        sum_a += history.amount_achieved
        sum_p += history.amount_pipeline
      end
    end
    sum_a > 0 ? sum_p / sum_a : 0.0
  end
  
end
