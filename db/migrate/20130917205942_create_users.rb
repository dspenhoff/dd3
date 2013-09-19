class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.string :organization
      t.string :role
      t.string :email
      t.string :phone
      t.string :username
      t.string :password
      t.timestamps
    end
  end
end
