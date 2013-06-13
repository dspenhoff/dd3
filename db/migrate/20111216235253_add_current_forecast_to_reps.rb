class AddCurrentForecastToReps < ActiveRecord::Migration
  def self.up
    add_column :reps, :current_forecast, :float
  end

  def self.down
    remove_column :reps, :current_forecast
  end
end
