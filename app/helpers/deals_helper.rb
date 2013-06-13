module DealsHelper
  
  # returns the toals of the likely values for the given array of deals
  def total_deals_likely_value(deals)
    sum = 0.0
    deals.each do |deal|
      sum += deal.most_likely_value
    end
    sum
  end
end
