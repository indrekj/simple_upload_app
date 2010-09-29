class RemoveMessagesTable < ActiveRecord::Migration
  def self.up
    drop_table :messages
  end

  def self.down
  end
end
