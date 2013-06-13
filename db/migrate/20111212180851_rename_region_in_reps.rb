class RenameRegionInReps < ActiveRecord::Migration
  def self.up
    rename_column :reps, :region, :region_name
  end

  def self.down
  end
end
