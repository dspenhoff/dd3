class Rep < ActiveRecord::Base
  belongs_to :region
  has_many :deals
  has_many :histories
  validates_presence_of :name, :allow_nil => false, :allow_blank => false, :message => "Must have a name"  
  validates_presence_of :region_id, :allow_nil => false, :allow_blank => false, :message => "Must select a region"  
  
  #
  # class methods
  #
  
  #require "regression"
  
  # returns the rep's current total open deals
  def open_deals
    sum = 0.0
    self.deals.each do |d|
      sum += d.most_likely_value
    end
    sum
  end

  # returns the rep's current total pipeline
  def current_pipeline
    sum = 0.0
    self.deals.each do |d|
      if d.is_pipeline then sum += d.most_likely_value end
    end
    sum
  end
  
  # returns the most likely value for all rep's deals with is_forecast flag set
  def current_forecast
    sum = 0.0
    self.deals.each do |d|
      if d.is_forecast then sum += d.most_likely_value end
    end
    sum
  end
  
  # returns the reps current forecast coverage
  def current_forecast_coverage
    self.current_pipeline / self.current_forecast
  end
  
  # returns the total number of deals currently open
  def num_deals
    sum = 0
    self.deals.each do |deal|
      if deal.stage_name != "Closed Won" && deal.stage_name != "Closed Lost"
        sum +=1
      end
    end
    sum
  end
  
  # returns the number of deals with is_pipeline flag set
  def num_pipeline
    sum = 0
    self.deals.each do |d| 
      if d.is_pipeline then sum += 1 end
    end
    sum
  end
  
  # returns the number of deals with is_forecast flag set
  def num_forecast
    sum = 0
    self.deals.each do |d| 
      if d.is_forecast then sum += 1 end
    end
    sum
  end
  
  # return the weighted average forecast accuracy (achieved / forecast) for rep's histories
  # the weighting factor is the amount forecast (terms cancel to give the ratio of sums)
  def forecast_accuracy
    sum_f = sum_a = 0.0
    self.histories.each do |h|
      sum_a += h.amount_achieved
      sum_f += h.amount_forecast
    end
    sum_f > 0.0 ? sum_a / sum_f : 0.0
  end
  
  # return the weighted average pipeline accuracy (achieved / pipeline) for rep's histories
  # the weighting factor is the amount pipeline (terms cancel to give the ratio of sums)
  def pipeline_accuracy
    sum_p = sum_a = 0.0
    self.histories.each do |h|
      sum_a += h.amount_achieved
      sum_p += h.amount_pipeline
    end
    sum_p > 0.0 ? sum_a / sum_p : 0.0
  end
  
  # return the weighted average forecast coverage (pipeline / forecast)
  # the weighting factor is the amount forecast and is implicit in the calc
  def forecast_coverage
    sum_f = self.sum_forecast_history
    sum_p = self.sum_pipeline_history
    sum_f > 0.0 ? sum_p / sum_f : 0.0    
  end
  
  # return the weighted average achieved coverage (pipeline / achieved)
  # the weighting factor is the amount forecast and is implicit in the calc 
  def achieved_coverage
    sum_a = self.sum_achieved_history
    sum_p = self.sum_pipeline_history
    sum_a > 0.0 ? sum_p / sum_a : 0.0    
  end
  
  # returns the rank value, i.e., the value used in the ranking calc
  # the rank value is the weighted average of the 'distance' of the rep's
  # historical forecast accuracy and the 'true' value of 1.0, and theta expressed in radians
  # weighting factor a is given in the calc and is entirely arbitrary
  def rank_value
    a = 0.8
    a * (1 - self.forecast_accuracy).abs + (1.0 - a) * self.amount_predicted_regression[:theta] * 3.14159 / 180.0
  end
  
  # returns a predicted value of the rep's amount achieved based on current forecast and pipeline values
  # uses a linear regression on the historical forecast, pipeline and achieved data
  # note: returns a hash combining the value and the theta (angle to 45-degree true forecast line)
  def amount_predicted_regression(mode)
    if self.histories.length == 0 then return Hash[:value => 0, :theta => 0] end
    if mode == :forecast # use only forecast values
      x = self.histories.collect { |h| [h.amount_forecast] }
    elsif mode == :pipeline # use only pipeline values
      x = self.histories.collect { |h| [h.amount_pipeline] }
    else # use both forecast and pipeline values
      x = self.histories.collect { |h| [h.amount_forecast, h.amount_pipeline] }
    end
    y = self.histories.collect { |h| h.amount_achieved }
    r = Regression.new
    r.lr(x, y, true) 
    if mode == :forecast
      Hash[:value => r.evaluate([self.current_forecast]), :theta => r.theta_degrees] 
    elsif mode == :pipeline
      Hash[:value => r.evaluate([self.current_pipeline]), :theta => r.theta_degrees] 
    else
      Hash[:value => r.evaluate([self.current_forecast, self.current_pipeline]), :theta => r.theta_degrees] 
    end
  end
  
  # returns the ratio of the regression current prediction to the current forecast
  def predicted_accuracy(mode)
    self.amount_predicted_regression(mode)[:value] / self.current_forecast
  end
  
  # this method simply uses the historical average
  def amount_predicted_average
    self.forecast_accuracy * self.current_forecast
  end
  
  #
  # methods to sum the rep's various history amounts
  #
  
  def sum_achieved_history
    sum = 0.0
    self.histories.each do |history|
      sum += history.amount_achieved
    end
    sum
  end
  
  def sum_forecast_history
    sum = 0.0
    self.histories.each do |history|
      sum += history.amount_forecast
    end
    sum
  end

  def sum_pipeline_history
    sum = 0.0
    self.histories.each do |history|
      sum += history.amount_pipeline
    end
    sum
  end
  
  
end
