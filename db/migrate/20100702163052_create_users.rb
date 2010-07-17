class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :email
      t.integer :lattitude
      t.integer :longitude
      t.integer :current_value
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
