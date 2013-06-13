# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120302205154) do

  create_table "customers", :force => true do |t|
    t.string   "company_name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "deal_field_histories", :force => true do |t|
    t.integer  "deal_id"
    t.boolean  "is_deleted"
    t.integer  "created_by_id"
    t.date     "created_date"
    t.float    "maximum_value"
    t.string   "field"
    t.date     "old_value"
    t.date     "new_value"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "deals", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "rep_id"
    t.float    "minimum_value"
    t.float    "most_likely_value"
    t.float    "maximum_value"
    t.date     "open_date"
    t.date     "expected_close_date"
    t.date     "actual_close_date"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.float    "probability"
    t.string   "name"
    t.boolean  "is_forecast"
    t.string   "stage_name"
    t.boolean  "is_pipeline"
  end

  create_table "histories", :force => true do |t|
    t.integer  "rep_id"
    t.date     "date"
    t.float    "amount_forecast"
    t.float    "amount_achieved"
    t.integer  "deals_pipeline"
    t.integer  "deals_achieved"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.float    "amount_pipeline"
    t.integer  "deals_forecast"
    t.integer  "num_closed_won"
    t.integer  "num_closed_lost"
    t.integer  "num_open_deals"
  end

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "reps", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "region_name"
    t.integer  "region_id"
    t.float    "current_forecast"
    t.float    "forecast"
  end

end
