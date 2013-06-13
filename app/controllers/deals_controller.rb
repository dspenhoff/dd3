# Copyright © by David M. Spenhoff. All rights reserved

include SharedMethods

class DealsController < ApplicationController
  
  # class constants to control the paged display of deals 
  @@page_size = 10 
  @@page_num = 0
  @@total_pages = 0 
  
  # GET /deals
  # GET /deals.xml
  def index
    session[:order_by] = "id"
    @order_by = session[:order_by_checked] = "none"
    session[:page_offset] = 0
    @deals = get_deals(session[:order_by], @@page_size, session[:page_offset])
    @page_title = "Deals"
  end
  
  #def index_deals
    # what is the purpose of this method? seems like nothing
  #end

  # GET /deals/1
  # GET /deals/1.xml
  def show
    @deal = Deal.find(params[:id])
    @page_title = "Deals > Show"
  end

  # GET /deals/new
  # GET /deals/new.xml
  def new
    @deal = Deal.new
    @reps = Rep.all
    @stages = sfdc_stages.collect{ |s| [sfdc_long_stage_name(s[:stage]), s[:stage].to_s] }
    @page_title = "Deals > New"
  end

  # GET /deals/1/edit
  def edit
    @deal = Deal.find(params[:id])
    @reps = Rep.all
    @stages = sfdc_stages.collect{ |s| [sfdc_long_stage_name(s[:stage]), s[:stage].to_s] }
    #@stages.unshift()
    @page_title = "Deals > Edit"
  end

  # POST /deals
  # POST /deals.xml
  def create
    @deal = Deal.new(params[:deal], :without_protection => true)
    @deal.apply_rules
    respond_to do |format|
      if @deal.save
        flash[:notice] = 'Deal was successfully created.'
        redirect_to(@deal)
      else
        @reps = Rep.all
        @stages = sfdc_stages.collect{ |s| [s[:stage].to_s, s[:stage].to_s] }
        @page_title = "Deals > New"
        render :action => "new" 
      end
    end
  end

  # PUT /deals/1
  # PUT /deals/1.xml
  def update
    @deal = Deal.find(params[:id])
    respond_to do |format|
      if @deal.update_attributes(params[:deal], :without_protection => true)
        @deal.apply_rules
        if @deal.save
          flash[:notice] = 'Deal was successfully updated.'
          redirect_to(@deal)
        end
      else
        render :action => "edit"
      end
    end
  end

  # DELETE /deals/1
  # DELETE /deals/1.xml
  def destroy
    @deal = Deal.find(params[:id])
    @deal.destroy
    redirect_to(deals_url)
  end 
  
  def scenario
    @page_title = "Deals > New scenario"
  end 
  
  def create_new_scenario
    # generate a new scenario of regions, reps, deals and histories based on params[]  
    # note the new scenario process (create) will first wipe out the existing scenario data 
    num_regions = params[:num_regions].to_i 
    num_reps = params[:num_reps].to_i
    num_deals = params[:num_deals].to_i
    num_histories = params[:num_histories].to_i
    over_achieve = params[:over_achieve].to_f
    under_achieve = params[:under_achieve].to_f
    new_scenario = Scenario.new
    if params[:deep_deals] == nil
      new_scenario.create(num_regions, num_reps, num_deals, num_histories, over_achieve, under_achieve)
    else
      new_scenario.create_deep(num_histories + 1, num_regions, num_reps, num_deals, num_histories, over_achieve, under_achieve)
    end
    #show the deals
    redirect_to(deals_url)
  end
  
  
  #
  # the following methods control the paging of the index display (deals listing)
  #
  
  # display the first page of deals
  def index_first_page
    session[:page_offset] = 0
    @deals = get_deals(session[:order_by], @@page_size, session[:page_offset])
    @order_by = session[:order_by_checked]
    @page_title = "Deals"
    render :index
  end
  
  # display the last page of deals
  def index_last_page
    session[:page_offset] = Deal.count - @@page_size
    if session[:page_offset] < 0 then session[:page_offset] = 0 end
    @deals = get_deals(session[:order_by], @@page_size, session[:page_offset])
    @order_by = session[:order_by_checked]
    @page_title = "Deals"
    render :index
  end
  
  # display the previous page of deals
  def index_previous_page
    session[:page_offset] = session[:page_offset] - @@page_size
    if session[:page_offset] < 0 then session[:page_offset] = 0 end
    @deals = get_deals(session[:order_by], @@page_size, session[:page_offset])
    @order_by = session[:order_by_checked]
    @page_title = "Deals"
    render :index
  end
  
  # display the first page of deals
  def index_next_page
    session[:page_offset] = session[:page_offset] + @@page_size
    if session[:page_offset] >= Deal.count then session[:page_offset] = Deal.count - @@page_size end
    @deals = get_deals(session[:order_by], @@page_size, session[:page_offset])
    @order_by = session[:order_by_checked]
    @page_title = "Deals"
    render :index
  end

  # loads deals in given order and with given offset (paging)
  def get_deals(order_by, limit, offset)
    #debugger
    flash.now[:notice] = Deal.count.to_s + " total deals"   
    @total_pages = (Deal.count.to_f / limit).ceil.to_i
    @page_num = (offset.to_f / limit).ceil.to_i + 1
    @deals_controller = true
    # old - Deal.all(:all, :order => order_by, :limit => limit, :offset => offset )
    Deal.all(:order => order_by, :limit => limit, :offset => offset )
  end
  
  #
  # the following method controls the display ordering of deals
  #
  
  def order_deals
    # the order_by filter
    @order_by = session[:order_by_checked] = params[:order_by]    # used in the view
    order_deals_by(@order_by)   # shared
    
    # page sizing
    session[:page_offset] = 0
    @deals = get_deals(session[:order_by], @@page_size, session[:page_offset])
    @page_title = "Deals"  
    render :index
  end
  
end
