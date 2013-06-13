class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.integer :rep_id
      t.date :date
      t.float :amount_forecast
      t.float :amount_achieved
      t.float :deals_pipeline
      t.float :deals_achieved
      
      t.timestamps
    end
  end

  def self.down
    drop_table :histories
  end
end
