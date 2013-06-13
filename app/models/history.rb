class History < ActiveRecord::Base
  belongs_to :rep
  
  def forecast_accuracy
    self.amount_achieved / self.amount_forecast
  end
  
  def achieved_coverage
    self.amount_pipeline / self.amount_achieved
  end
  
  def forecast_coverage
    self.amount_pipeline / self.amount_forecast
  end
  
end
