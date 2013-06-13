class AddRegionToRep < ActiveRecord::Migration
  def self.up
    add_column :reps, :region, :string
  end

  def self.down
    remove_column :reps, :region
  end
end
