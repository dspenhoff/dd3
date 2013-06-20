# Copyright © by David M. Spenhoff. All rights reserved

# calculates a least squares best fit linear regression 
# i.e., y = w0 + w1*x1 + ... wn*xn
# given: matrix x of sample features, array y of value for each sample
# e.g., x is matrix of forecast and pipeline, y is the actual achieved s

require 'matrix'

class Regression
  
  def initialize
  end
  
  def lr(x, y, intercept)
    # x is a standard Ruby array-of-arrays matrix containing sample values
    # y is an array of values associated with each sample in x
    # intercept is a boolean indicating whether to calculate the linear intercept
    # i.e. add a first column of ones
    # typically intercept will be true
    # this method makes a Matrix and Vector object from x and y respectively
    # and uses the closed-form matrix calculation to determine the best-fit linear weights
    
    # note: all data external (provided or returned) to this class are regular ruby
    # arrays or scalers; internally these are converted to Matrix and Vector objects

    #puts "+++++ regression - lr"
    if intercept then x.collect! { |e| e.insert(0, 1.0) } end
    xm = Matrix.rows(x)
    yv = Vector.elements(y)
    @intercept = intercept
    @size = [xm.row_size, xm.column_size]
    @wv = (xm.transpose * xm).inv * xm.transpose * yv
    @w = @wv.to_a
    @objective = lr_objective(xm, yv)
  end
  
  # returns the value of the linear fit for the given x-value (an array)
  # e.g., used to predict the y value for a given sample x
  def evaluate(x)
    if @intercept then x.insert(0, 1.0) end 
    (Vector.elements(x).covector * @wv)[0]
  end
  
  # returns the angular difference betweeen the linear fit line and the 45-degree "true fit" line
  # theta is in radians, e.g., 45 degrees = pi / 4 = .7854 (approx)
  def theta
    theta_m(1.0)    # m = 1 for the 45 degree line
  end
  
  # calcs theta vs a line (2d) with given slope m
  # e.g. for a 2.5:1 pipeline coverage line m = 0.4
  def theta_m(m)
    # m is a scalar value, the slope of a line through the origin in 2d space
    # uses @w[1] as slope of lr line, i.e., assumes @intercept == true and 2d lr
    # todo: replace with the more general acos calc (e.g., for planar angles)
    Math.atan(((m - @w[1]) / (1 + m * @w[1])).abs) 
  end
  
  # returns theta expressed in degrees
  def theta_degrees
    theta_m_degrees(1.0)
  end
  
  def theta_m_degrees(m)
    theta_m(m) * 180 / Math::PI
  end

  attr_reader :w, :intercept, :size, :objective
  
  private
  
  # calculates the linear regression abjective function for the given parameters
  def lr_objective(xm, yv)
    zv = xm * @wv - yv
    sum = 0
    zv.size.times do |i|
      sum += zv[i] * zv[i]
    end
    sum /= 2 * zv.size
  end
  
  
end