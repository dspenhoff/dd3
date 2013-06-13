class CreateReps < ActiveRecord::Migration
  def self.up
    create_table :reps do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :reps
  end
end
