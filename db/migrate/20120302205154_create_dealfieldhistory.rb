class CreateDealfieldhistory < ActiveRecord::Migration
  def self.up
    create_table :deal_field_histories do |t|
      t.integer :deal_id
      t.boolean :is_deleted
      t.integer :created_by_id
      t.date :created_date
      t.float :maximum_value
      t.string :field
      t.date :old_value
      t.date :new_value

      t.timestamps
    end
  end

  def self.down
    drop_table :deal_field_histories
  end
end
