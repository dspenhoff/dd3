class AddNumCloseToHistories < ActiveRecord::Migration
  def self.up
    add_column :histories, :num_closed_won, :integer
    add_column :histories, :num_closed_lost, :integer
  end

  def self.down
    remove_column :histories, :num_closed_won
    remove_column :histories, :num_closed_lost
  end
end
