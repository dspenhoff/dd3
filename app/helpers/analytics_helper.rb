module AnalyticsHelper
  
  # returns the total number of deals for the given array of summary objects
  def summary_total_num_deals(summaries)
    sum = 0
    summaries.each do |summary|
      sum += summary.num_deals
    end
    sum
  end
  
  # returns the total of the means for the given array of summary objects
  def summary_total_means(summaries)
    sum = 0.0
    summaries.each do |summary|
      sum += summary.mean
    end
    sum
  end
  
  # returns the total of the factored means for the given array of summary objects
  def summary_total_f_means(summaries)
    sum = 0.0
    summaries.each do |summary|
      sum += summary.f_mean
    end
    sum
  end
  
  # returns the total of the modes for the given array of summary objects
  def summary_total_modes(summaries)
    sum = 0.0
    summaries.each do |summary|
      sum += summary.mode
    end
    sum
  end

  # returns the total of the factored modes for the given array of summary objects
  def summary_total_f_modes(summaries)
    sum = 0.0
    summaries.each do |summary|
      sum += summary.f_mode
    end
    sum
  end
  
  # returns the total current forecast for the given array of 'source' objects
  # a source may be a region or a rep
  def source_total_forecasts(sources)
    sum = 0.0
    sources.each do |source|
      sum += source.current_forecast
    end
    sum
  end

  # returns the total current pipeline for the given array of 'source' objects
  # a source may be a region or a rep
  def source_total_pipelines(sources)
    sum = 0.0
    sources.each do |source|
      sum += source.current_pipeline
    end
    sum
  end  

  # returns the total current pipeline for the given array of 'source' objects
  # a source may be a region or a rep
  def source_total_open_deals(sources)
    sum = 0.0
    sources.each do |source|
      sum += source.open_deals
    end
    sum
  end
  
  # returns the total number of deals (open deals) for the given array of 'source' objects
  # a source may be a region or a rep
  def source_total_num_deals(sources)
    sum = 0
    sources.each do |source|
      sum += source.num_deals
    end
    sum
  end
  
  # returns the total number of pipeline deals for the given array of 'source' objects
  # a source may be a region or a rep
  def source_total_num_pipelines(sources)
    sum = 0
    sources.each do |source|
      sum += source.num_pipeline
    end
    sum
  end
  
  # returns the total number of forecast deals for the given array of 'source' objects
  # a source may be a region or a rep
  def source_total_num_forecasts(sources)
    sum = 0
    sources.each do |source|
      sum += source.num_forecast
    end
    sum
  end
end
