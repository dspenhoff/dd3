module RegionsHelper
  
  # returns the total current forecast for the given array of regions
  def total_region_forecast(regions)
    sum = 0.0
    regions.each do |region|
      sum += region.current_forecast
    end
    sum
  end
 
  # returns the total current pipeline for the given array of regions
  def total_region_pipeline(regions)
    sum = 0.0
    regions.each do |region|
      sum += region.current_pipeline
    end
    sum
  end

  # returns the total number of reps for the given array of regions
  def total_region_num_reps(regions)
    sum = 0
    regions.each do |region|
      sum += region.num_reps
    end
    sum
  end 
  
  # returns the total number of deals for the given array of regions
  def total_region_num_deals(regions)
    sum = 0
    regions.each do |region|
      sum += region.num_deals
    end
    sum
  end
  
  # returns the total number of deals forecast for the given array of regions
  def total_region_num_forecast(regions)
    sum = 0
    regions.each do |region|
      sum += region.num_forecast
    end
    sum
  end
  
  # returns the total number of deals forecast for the given array of regions
  def total_region_num_pipeline(regions)
    sum = 0
    regions.each do |region|
      sum += region.num_pipeline
    end
    sum
  end
  
  # returns the forecast accuracy factored total forecast for the collection of regions
  def total_region_factored_forecast(regions)
    sum = 0.0
    regions.each do |region|
      sum += region.current_forecast * region.forecast_accuracy
    end
    sum
  end
  
  # returns the pipeline accuracy factored total forecast for the collection of regions
  def total_region_factored_pipeline(regions)
    sum = 0.0
    regions.each do |region|
      sum += region.current_pipeline * region.pipeline_accuracy
    end
    sum
  end
  
end
