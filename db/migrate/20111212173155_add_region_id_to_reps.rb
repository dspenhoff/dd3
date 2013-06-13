class AddRegionIdToReps < ActiveRecord::Migration
  def self.up
    add_column :reps, :region_id, :integer
  end

  def self.down
    remove_column :reps, :region_id
  end
end
