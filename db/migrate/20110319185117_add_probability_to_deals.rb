class AddProbabilityToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :probability, :float
  end

  def self.down
    remove_column :deals, :probability
  end
end
