# Copyright © by David M. Spenhoff. All rights reserved

class Visualization
	def initialize
		# initialize base url for google charts
		@chart_url = "http://chart.apis.google.com/chart?"
		
		# initialize title to generic 
		@title = "Marketing+Optimization Chart"
	end
	
	# sets the chart title
	def set_title(t)
		@title = t
	end

	# returns the google charts url
	def get_url
		@chart_url
	end
	
  # makes the parameter string for probability functions (pdf, cdf) line chart
  def make_probability_functions_chart(pdf, cdf, mean)
  
  	# y-axis scaling factors
  	pdf_scale = 100
  	cdf_scale = 99.5
  	
  	# x-axis scaling and layout factors
  	@min = pdf.min_range
  	@max = pdf.max_range
  	@step = 100 * pdf.step.to_f / (@max - @min)
  	@x_min = 100 * (@min / 100).to_i
  	@x_max = 100 * ((@max / 100).to_i + 1)
  	@x_steps = (@x_max - @x_min) / 100
  	
   	# make the pdf line dataset
  	pdf_array = Array.new
  	pdf.length.times do |i|
  		pdf_array << pdf.get(i)
  	end
		pdf_data = make_line(pdf_array, pdf_scale, true)
		
		#make the cdf line dataset
  	cdf_array = Array.new
  	cdf.length.times do |i|
  		cdf_array << cdf.get(i)
  	end
		cdf_data = make_line(cdf_array, cdf_scale, true)
		
		# make the mean, mode, median line datasets
		mean_data = make_vertical_line(mean)
		# removing mode - ambiguous and potentially misleading
		#mode_data = make_vertical_line(pdf.mode)
		median_data = make_vertical_line(cdf.median)
		
		# make the google charts url parameter string
		# note: the commented lines are related to the mode (deleted because it is ambiguous and misleading)
  	@chart_url += "cht=lxy"
  	@chart_url += "&chtt=" + @title
  	@chart_url += "&chs=600x400"
  	# @chart_url += "&chd=t:" + median_data + "|" + mode_data + "|" + mean_data + "|" + pdf_data + "|" + cdf_data
  	@chart_url += "&chd=t:" + median_data + "|" + mean_data + "|" + pdf_data + "|" + cdf_data
  	@chart_url += "&chxt=y,x,r"
  	@chart_url += "&chxr=0,0.0,1.0|1," + @x_min.to_s + "," + @x_max.to_s + "|2,0.0,1.0"
  	@chart_url += "&chxtc=1,5"
  	#@chart_url += "&chco=990000,330066,009900,ff6633,3366ff"
  	@chart_url += "&chco=990000,009900,ff6633,3366ff"
  	#@chart_url += "&chls=3|3|3|5|5"
  	@chart_url += "&chls=3|3|5|5"
  	@chart_url += "&chg=" + @x_steps.to_s + ",10"  
		@chart_url += "&chma=50,50,50,50"
  end

  # makes the parameter string for probability functions (pdf, cdf) mixed histo/line chart
  def make_probability_functions_chart_histo(pdf, cdf, mean)
  
  	# y-axis scaling factors
  	pdf_scale = 100
  	cdf_scale = 99.5
  	
  	# x-axis scaling and layout factors
  	@min = pdf.get_min_range
  	@max = pdf.get_max_range
  	@step = 100 * pdf.step.to_f / (@max - @min)
  	@x_min = 100 * (@min / 100).to_i
  	@x_max = 100 * ((@max / 100).to_i + 1)
  	@x_steps = (@x_max - @x_min) / 100
  	
   	# make the pdf line dataset
  	pdf_array = Array.new
  	pdf.length.times do |i|
  		pdf_array << pdf.get(i)
  	end
		pdf_data = make_line(pdf_array, pdf_scale, true)
		
		#make the cdf line dataset
  	cdf_array = Array.new
  	cdf.length.times do |i|
  		cdf_array << cdf.get(i)
  	end
		cdf_data = make_line(cdf_array, cdf_scale, true)
		
		# make the mean, mode, median line datasets
		mean_data = make_vertical_line(mean)
		mode_data = make_vertical_line(pdf.mode)
		median_data = make_vertical_line(cdf.median)
		
		# make the google charts url parameter string
  	@chart_url += "cht=bvg"
  	@chart_url += "&chtt=" + @title
  	@chart_url += "&chs=600x400"
  	@chart_url += "&chd=t:" + pdf_data + "|" + cdf_data
  	@chart_url += "&chm=D,3366ff,1,0,5"
  	@chart_url += "&chxt=y,x,r"
  	@chart_url += "&chxr=0,0.0,1.0|1," + @x_min.to_s + "," + @x_max.to_s + "|2,0.0,1.0"
  	@chart_url += "&chxtc=1,5"
  	@chart_url += "&chco=3366ff"

  end
   
  # make the most likely value distribution histo
  def make_most_likely_chart_histo(deals)
    # make an array of most likely values 
    mlv_array = deals.collect{ |deal| deal.most_likely_value }
    
    # make the histo chart 
    mlv_min = 0;
    mlv_max = mlv_array.max
    mlv_step = (mlv_max - mlv_min).to_f / 9
    make_histo(mlv_array, 10, mlv_min, mlv_max, mlv_step, "Most Likely Values Frequency Distribution")     
  end
  
  # make the deal probability value distribution histo
  def make_prob_chart_histo(deals)
    # make the histo array
    p_array = deals.collect{ |deal| deal.probability }   
    
    # make the histo chart
    make_histo(p_array, 11, 0.0, 1.0, 0.1001, "Deal Stages/Win Probabilities Frequency Distribution")
  end
  
  # makes the achieved vs. forecast scatter plot chart
  def make_chart_achieved_vs_x(a_array, x_array, avx_type, alpha)
    # a_array is the array of achieved values, f_array is the array of associated forecasts
    # i.e., assumes that a_array[i] and f_array[i] are a pair

		# set the scale factor and make the data string
		n = a_array.length
		scale_max = [a_array.max, x_array.max].max.to_f * 1.1
		scale_factor = 100.0 / scale_max
		a_string = a_array.collect{|a| (a * scale_factor).round }.join(",") + ",0," + (100 / alpha).to_s
		x_string = x_array.collect{|x| (x * scale_factor).round }.join(",") + ",0,100"
		
    # make the google charts url parameter string
  	@chart_url += "cht=s"
  	@chart_url += "&chtt=" + @title
  	@chart_url += "&chs=600x400"
  	@chart_url += "&chd=t:" + x_string + "|" + a_string
  	@chart_url += "&chm=o,0000ff,0,-1,0|o,3366ff,0,0:" + (n - 1).to_s + ":,10|D,dddddd,1," + n.to_s + ":,1,-1"
  	@chart_url += "&chxt=x,x,y,y"
  	@chart_url += "&chxl=1:|" + avx_type + "|3:|Achieved|"
  	@chart_url += "&chxp=1,95|3,95"
  	@chart_url += "&chxr=0,0," + (scale_max / 1000).to_s + "|2,0," + (scale_max / 1000).to_s

  end
  
  private
  
  # makes a line dataset as a comma delimited string, scaled for chart
  def make_line(source, scale, make_x_data)
  	# source is one of pdf_array, cdf_array, lc_array
  	y_array = Array.new
  	x_array = Array.new
  	x = 0
  	source.length.times do |i|
			source[i] < 0.05 ? y_array[i] = 0.5 : y_array[i] = source[i] * scale
			x_array[i] = x 
			x += @step
  	end
  	if make_x_data
  		s = x_array.join(",") + "|" + y_array.join(",")
  	else
  		s = y_array.join(",")
  	end
  	s		# return value
  end
  
  # makes a vertical (mean, mode, median) line dataset
  def make_vertical_line(source)
  	# source is one of mean, mode, median
		value = 100.0 * (source - @min).to_f / (@max - @min) 
		value.to_s + "," + value.to_s + "|0,100" 
	end
	
	# makes the histogram chart from the given data 
	def make_histo(a, n, a_min, a_max, step, title)
    a.sort!
    @step = step

    # make the histo array
    h_array = Array.new(n, 0)
    limit = a_min
    k = 0
    a.each do |a_data|
      while a_data > limit
        limit += @step
        k += 1
      end
      h_array[k] += 1
    end
    
    h_max = h_array.max    
    h_data = make_line(h_array, 99.5 / h_max, false)
    # make the google charts url parameter string
  	@chart_url += "cht=bvs"
  	@chart_url += "&chtt=" + title
  	@chart_url += "&chs=600x400"
  	@chart_url += "&chd=t:" + h_data
  	@chart_url += "&chm=D,3366ff,1,0,10"
  	@chart_url += "&chxt=y,x"
  	@chart_url += "&chxr=0,0.0," + h_max.to_s + "|1," + a_min.to_s + "," + a_max.to_s 
  	@chart_url += "&chxtc=1,5" 
  	@chart_url += "&chbh=" + ((500 / n).to_i).to_s 	
  	@chart_url += "&chco=3366ff"	  
	end
end