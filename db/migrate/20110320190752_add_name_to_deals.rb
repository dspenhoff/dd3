class AddNameToDeals < ActiveRecord::Migration
  def self.up
    add_column :deals, :name, :string
  end

  def self.down
    remove_column :deals, :name
  end
end
