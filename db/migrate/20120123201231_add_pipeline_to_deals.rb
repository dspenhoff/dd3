class AddPipelineToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :is_pipeline, :boolean
  end

  def self.down
    remove_column :deals, :is_pipeline
  end
end
