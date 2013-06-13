class AddColumnsToHistories < ActiveRecord::Migration
  def self.up
    add_column :histories, :amount_pipeline, :float
    add_column :histories, :deals_forecast, :integer
    change_column :histories, :deals_pipeline, :integer
    change_column :histories, :deals_achieved, :integer
  end

  def self.down
    drop_column :histories, :amount_pipeline
    drop_column :histories, :deals_forecast
    change_column :histories, :deals_pipeline, :float
    change_column :histories, :deals_achieved, :float
  end
end
