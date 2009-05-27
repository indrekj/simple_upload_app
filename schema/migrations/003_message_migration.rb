class MessageMigration < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :body
      t.string :author
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
