class Deal < ActiveRecord::Base
  belongs_to :rep
  validates_presence_of :rep_id, :allow_nil => false, :allow_blank => false, :message => "Must select a rep"
  validates_presence_of :stage_name, :allow_nil => false, :allow_blank => false, :message => "Must select a stage"
  validates_presence_of :name, :allow_nil => false, :allow_blank => false, :message => "Must have a description"
  validates_presence_of :most_likely_value, :allow_nil => false, :allow_blank => false, :message => "Must have a most likely value"
  validates_numericality_of :most_likely_value, :message => "Most likely value must be a number"
  
  def deal_is_pipeline
    (self.probability >= 0.5 && self.probability < 1.0)
  end
  
  def deal_is_forecast
    (self.probability >= 0.75 && self.probability < 1.0)
  end
  
  #
  # rules used for deal creation/update
  #
  
  def apply_rules
    self.deal_probability_rule
    self.nil_value_rule
    self.forecast_pipeline_rule
  end
  
  def deal_probability_rule
    if self.stage_name != nil then self.probability = sfdc_stage_probability(self.stage_name) end
  end
  
  def nil_value_rule
    if self.most_likely_value != nil
      if self.minimum_value == nil then self.minimum_value = self.most_likely_value end
      if self.maximum_value == nil then self.maximum_value = self.most_likely_value end
    end
  end
  
  def forecast_pipeline_rule
    self.is_forecast = self.deal_is_forecast
    self.is_pipeline = self.deal_is_pipeline || self.is_forecast
  end
  
  
end
