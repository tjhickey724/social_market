class CreateStocks < ActiveRecord::Migration
  def self.up
    create_table :stocks do |t|
      t.string :exchange
      t.string :company
      t.float :bid # price for selling 1 shares
      t.float :ask # price for buying 1 shares
      t.timestamps
    end
  end

  def self.down
    drop_table :stocks
  end
end
