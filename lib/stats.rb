# Copyright © by David M. Spenhoff. All rights reserved

# this file implements various probability and statistical functions 
# used by various analytics functions

# =========================
# probability density function ('pdf')

class Pdf

	# constructor, initializes the data structure
	def initialize
		@pdf_array = Array.new
		@min_range = 0
		@max_range = 0
		25.times do |i|
			@pdf_array[i] = 0.0
		end
	end
	
	# updates the cdf array element based on the given value
	def update(x)
		# determine appropriate pdf_array and increment it
		k = ((x - @min_range) / (@max_range - @min_range) * @pdf_array.length).to_i
		@pdf_array[k] += 1.0
	end
	
	# normalizes pdf_array to 'probability values'
	def normalize(n)
		@pdf_array.length.times do |i|
			@pdf_array[i] /= n
		end
	end
	
	# calculates the mode (most frequest value) of the distribution
	# i.e., the point with the maximum probability function value
	def mode
		delta = (@max_range - @min_range).to_f / @pdf_array.length
		my_mode = x = @min_range
		max = 0
		@pdf_array.length.times do |i|
			if @pdf_array[i] > max 
				my_mode = x
				max = @pdf_array[i]
			end
			x += delta
		end
		my_mode
	end
	
	# returns the size of pdf_array
	def length
		@pdf_array.length
	end
	
	# returns the 'step' size for the function
	def step
		(@max_range - @min_range).to_f / @pdf_array.length
	end
	
	# returns the ith element of pdf_array
	def get(i)
		@pdf_array[i]
	end
	
	# standard accessors
	attr_accessor :max_range, :min_range
	
	# dumps the pdf to the console for debugging
	def dump
		x = @min
		delta = (@max_range - @min_range).to_f / @pdf_array.length
		puts ">>>> pdf"
		@pdf_array.length.times do |i|
			puts "x, pdf(x) = " + x.to_s + ", " + @pdf_array[i].to_s
			x += delta		
		end
	end
end

# =========================
# cumulative distribution function ('cdf') 

class Cdf

	# constructor, initializes the data structure
	def initialize
		@cdf_array = Array.new
		@min_range = 0
		@max_range = 0
		25.times do |i|
			@cdf_array[i] = 0.0
		end
	end
	
	# makes the cdf from the given pdf
	def from_pdf(pdf)
		@min_range = pdf.min_range
		@max_range = pdf.max_range
		@delta_range = (@max_range - @min_range).to_f / @cdf_array.length		
		@cdf_array[0] = pdf.get(0)
		(@cdf_array.length - 1).times do |i|
			@cdf_array[i + 1] = @cdf_array[i] + pdf.get(i + 1)
		end
	end
		
	# calculates the cdf value F(x) = P{X <= x} for given x
	def F(x)
		if x <= @min_range 
			y = 0
		elsif x >= @max_range
			y = 1
		else
			# interpolate between appropriate cdf_array elements
			k = ((x - @min_range) / @delta_range).to_i
			x_k = @min_range + k * @delta_range
			(x - x_k) * (@cdf_array[k+1] - @cdf_array[k]) / @delta_range + @cdf_array[k] # return value
		end
	end	
	
	# calculates the inverse of the F function by interpolation
	def F_inverse(y)
		k = 0
		@cdf_array.length.times do |i|
			if @cdf_array[i] >= y
				k = i
				break
			end
		end
		
		if k == 0 
			x = @min_range + @delta_range * y / @cdf_array[0]
		else
			# interpolate to get the median value
			x = @min_range + @delta_range * (k - 1) + @delta_range * (y - @cdf_array[k-1]) / (@cdf_array[k] - @cdf_array[k-1])
		end
		
		x
	end
	
	# calculates the median of the underlying probability distribution
	# the median is defined as P{X <= median} = .5 and thus can be calculated as F_inverse(.5)
	def median
		F_inverse(0.5)
	end
	
	# returns the size of pdf_array
	def length
		@cdf_array.length
	end
	
	# returns the 'step' size for the function
	def step
		(@max_range - @min_range).to_f / @cdf_array.length
	end
	
	# returns the ith element of pdf_array
	def get(i)
		@cdf_array[i]
	end
	
	attr_accessor :max_range, :min_range
	
	# dumps the cdf to the console for debugging
	def dump
		x = @min_range
		puts ">>>> cdf"
		@cdf_array.length.times do |i|
			puts "x, cdf(x) = " + x.to_s + ", " + @cdf_array[i].to_s
			x += @delta_range		
		end
	end
end	
	

