module RepsHelper
  
  # returns the total number of deals for the given collection of reps
  def total_rep_num_deals(reps)
    sum = 0
    reps.each do |rep|
      sum += rep.num_deals
    end
    sum  
  end
  
  # returns the total number of deals forecast for the given collection of reps
  def total_rep_num_deals_forecast(reps)
    sum = 0
    reps.each do |rep|
      sum += rep.num_forecast
    end
    sum
  end
  
  # returns the total of the current forecast for the given collection of reps
  def total_rep_forecast(reps)
    sum = 0.0
    reps.each do |rep|
      sum += rep.current_forecast
    end
    sum
  end
  
  # returns the total of the current pipeline for the given collection of reps
  def total_rep_pipeline(reps)
    sum = 0.0
    reps.each do |rep|
      sum += rep.current_pipeline
    end
    sum
  end
    
  # returns the average forecast average for the given collection of reps
  # note the return value needs to be multiplied by 100 to get a percentage
  def average_rep_forecast_accuracy(reps)
    sum = 0.0
    reps.each do |rep|
      sum += rep.forecast_accuracy
    end
    sum / reps.length
  end  
  
  # returns the average pipeline coverage for the given collection of reps
  # note the return value needs to be multiplied by 100 to get a percentage
  def average_rep_forecast_coverage(reps)
    sum = 0.0
    reps.each do |rep|
      sum += rep.forecast_coverage
    end
    sum / reps.length
  end
  
  # returns the total (aggregate) forecast coverage for the given collection of reps
  # note the return value needs to be multiplied by 100 to get a percentage
  def total_rep_forecast_coverage(reps)
    sum_f = sum_p = 0.0
    reps.each do |rep|
      sum_f += rep.amount_forecast
      sum_p += rep.amount_pipeline
    end
    sum_f > 0 ? sum_p / sum_f : 0.0
  end
  
  # returns the historical forecast coverage for the collection of reps, aggregated over the reps' histories
  # see caveats above
  def total_rep_forecast_coverage(reps)
    sum_f = sum_p = 0.0
    reps.each do |rep|
      rep.histories.each do |history|
        sum_f += history.amount_forecast
        sum_p += history.amount_pipeline
      end
    end
    sum_f > 0 ? sum_p / sum_f : 0.0
  end
  
  # returns the historical achieved coverage for the collection of reps, aggregated over the reps' histories
  # see caveats above
  def total_rep_achieved_coverage(reps)
    sum_a = sum_p = 0.0
    reps.each do |rep|
      rep.histories.each do |history|
        sum_a += history.amount_achieved
        sum_p += history.amount_pipeline
      end
    end
    sum_a > 0 ? sum_p / sum_a : 0.0
  end
  
  # returns the total forecast predicted for the given collection of reps
  # using the linear regression on the historical data
  def total_rep_predicted_regression(reps)
    sum = 0.0
    reps.each do |rep|
      sum += rep.amount_predicted_regression
    end
    sum
  end
  
  
  
  # returns the total forecast predicted for the given collection of reps
  # using the average achievement on the historical data
  def total_rep_predicted_average(reps)
    sum = 0.0
    reps.each do |rep|
      sum += rep.amount_predicted_average
    end
    sum
  end
    
end
