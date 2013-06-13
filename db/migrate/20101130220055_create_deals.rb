class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.integer :customer_id
      t.integer :rep_id
      t.float :minimum_value
      t.float :most_likely_value
      t.float :maximum_value
      t.date :open_date
      t.date :expected_close_date
      t.date :actual_close_date

      t.timestamps
    end
  end

  def self.down
    drop_table :deals
  end
end
