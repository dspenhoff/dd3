class AddNumOpenDealsToHistories < ActiveRecord::Migration
  def self.up
    add_column :histories, :num_open_deals, :integer
  end

  def self.down
    remove_column :histories, :num_open_deals
  end
end
