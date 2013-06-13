class AddIsForecastToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :is_forecast, :boolean
  end

  def self.down
    remove_column :deals, :is_forecast
  end
end
