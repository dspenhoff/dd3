class AddForecastToRep < ActiveRecord::Migration
  def self.up
    add_column :reps, :forecast, :float
  end

  def self.down
    remove_column :reps, :forecast
  end
end
