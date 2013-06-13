module SharedMethods
  
  #
  # methods related to stages and win probabilities
  #

  # returns an array of hashes containing the sfdc stage names and associated probabilities
  # these are the sfdc defaults plus a short name for compact display
  def sfdc_stages
    [
      {:stage => "Prospecting", :short_stage => "Prospect - 10%", :probability => 10.0},
      {:stage => "Qualification", :short_stage => "Qualify - 10%", :probability => 10.0}, 
      {:stage => "Needs Analysis", :short_stage => "Needs - 20%", :probability => 20.0},
      {:stage => "SQL-30", :short_stage => "SQL - 30%", :probability => 30.0}, 
      {:stage => "Value Proposition", :short_stage => "Value Prop - 50%", :probability => 50.0}, 
      {:stage => "Id. Decision Makers", :short_stage => "Deciders - 60%", :probability => 60.0}, 
      {:stage => "Perception Analysis", :short_stage => "Perception - 70%", :probability => 70.0}, 
      {:stage => "Proposal/Price Quote", :short_stage => "Quote - 75%", :probability => 75.0},
      {:stage => "Negotiation/Review", :short_stage => "Negotiate - 90%", :probability => 90.0},
      {:stage => "Closed Won", :short_stage => "Won", :probability => 100.0},
      {:stage => "Closed Lost",  :short_stage => "Lost", :probability => 0.0}
    ]
  end
  
  # returns the short name associated with the given sfdc stage name
  def sfdc_short_stage_name(s)
    short_name = ""   # default if no match
    sfdc_stages.each do |stage|
      if stage[:stage] == s
        short_name = stage[:short_stage]
        break
      end
    end
    short_name   # return value 
  end 
  
  # returns the given stage name with the probability as a suffix
  def sfdc_long_stage_name(s)
    long_name = ""    # default if no match
    sfdc_stages.each do |stage|
      if stage[:stage] == s
        long_name = s + " - " + stage[:probability].to_int.to_s + "%"
        break
      end
    end
    long_name    
  end
   
  # returns the probability associated with the given sfdc stage name
  # note: normalizes to range [0.0, 1.0]
  def sfdc_stage_probability(s)
    probability = 0.0
    sfdc_stages.each do |stage|
      if stage[:stage] == s
        probability = stage[:probability] / 100.0
        break
      end
    end
    probability   # return value 
  end
  
  #
  # method related to ordering deals; sets a session variable used in querying deals
  # used in deals, reps and regions controllers
  # putting it here for DRY instead of replicating three times
  #
  
  def order_deals_by(order_by)
    case order_by 
     when "none"
       session[:order_by] = "actual_close_date DESC"
     when "stage"
       session[:order_by] = "probability DESC"
     when "min_value"
       session[:order_by] = "minimum_value"
     when "max_value"
       session[:order_by] = "maximum_value DESC"
     when "most_likely_value"
       session[:order_by] = "most_likely_value DESC"
     when "is_pipeline"
       session[:order_by] = "is_pipeline DESC"
     else
       # should not happen, reset the deals display
       session[:order_by] = "id"  
     end
  end
  
  # make the sfdc methods available to views (as helpers)
  
  def self.included(base)
    base.send :helper_method, :sfdc_stages if base.respond_to? :helper_method
  end
  def self.included(base)
    base.send :helper_method, :sfdc_stage_short_name if base.respond_to? :helper_method
  end
  def self.included(base)
    base.send :helper_method, :sfdc_stage_probability if base.respond_to? :helper_method
  end
  
end