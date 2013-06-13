class AddStageNameToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :stage_name, :string
  end

  def self.down
    remove_column :deals, :stage_name
  end
end
