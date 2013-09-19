# Copyright (c) by David M. Spenhoff. All rights reserved

class User < ActiveRecord::Base
	has_many :reps
	has_many :regions
	has_many :deals
	has_many :histories
	
	validates_uniqueness_of :username 
	validates_confirmation_of :password, :on => :create
	validates_length_of :password, :within => 8..40 
end