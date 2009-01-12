class AddLinksTableMigration < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.string :url
      t.string :description
      t.string :creator_ip, :length => 20
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
