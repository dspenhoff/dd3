# responds to spreadsheet data input for a few "express" analytics

require 'rubygems'
require 'roo'

class ExpressController < ApplicationController
  
  ##
  #
  # get a spreadsheet file (xls or xlsx) from the user, upload it, open it, process it
  #
  ##  
  
  def index
    render 'upload_file'
  end

  def show
  end

  def edit
  end

  def new
  end
  
  def upload_file
    # in conjunction with the DataFile model, uploads a customer selected file to root/tmp/tmp_data 
    # opens the file and processes the contents
    
    file_path = DataFile.save(params[:upload])
    
    case file_type(file_path)
    when 'xls'
      ss = Roo::Excel.new file_path
    when 'xlsx'
      ss = Roo::Excelx.new file_path
    else
      File.delete(file_path)
      flash.now[:error] = "File type was not recognized. \nPlease select an Excel compatible file (.xls or .xlsx)."
      render 'upload_file'
    end 
    
    extract_rows(ss) 
    extract_data
    File.delete(file_path)
    @sim = Simulation.new
    @sim.quick_simulate(@deals)
    #debugger
    render :template => 'analytics/simulate_deals'
         
  end
  
  def file_type(file_path)
    # determines whether the file type is xls or xlsx based on the file extension
    # returns the file type or nil
    i = file_path.rindex('.')
    if i == nil then return nil end
    case file_path.slice(i+1, file_path.length)
    when 'xls' 
      return 'xls'
    when 'xlsx' 
      return 'xlsx'
    else
      return nil
    end
  end  
  
  def extract_rows(s)
    # processes the spreadsheet object to get the rows
    @rows = Array.new
    @num_rows = 0
    s.each do |row|
      @num_rows = @num_rows + 1
      @rows << row
    end
  end
  
  def extract_data
    # assumes first row is heading, other rows are correctly formatted data in the order indicated
    
    col_hash =                 { :name => 0 }
    col_hash = col_hash.merge( { :value => 1 })
    col_hash = col_hash.merge( { :probability => 2 })
    col_hash = col_hash.merge( { :rep => 3 })
    col_hash = col_hash.merge( { :region => 4 })
    
    @deals = Array.new
    @reps = Array.new
    @regions = Array.new
    
    @num_rows.times do |i|
      if i > 0        # skip first row (heading)
        deal = Deal.new
        deal.name = @rows[i][col_hash[:name]]
        deal.most_likely_value = @rows[i][col_hash[:value]]
        deal.minimum_value = deal.most_likely_value
        deal.maximum_value = deal.most_likely_value
        deal.probability = @rows[i][col_hash[:probability]]
        #deal.rep = @rows[i][col_hash[:rep]]
        #deal.region = @rows[i][col_hash[:region]]
        @deals << deal
      end
    end
  end
  
end

