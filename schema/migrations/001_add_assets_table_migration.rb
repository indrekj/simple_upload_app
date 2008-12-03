class AddAssetsTableMigration < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string  :title, :length => 30
      t.string  :category, :length => 30
      t.string  :author, :default => 'itimees', :length => 30
      t.integer :year, :default => Time.now.strftime("%Y").to_i, :length => 4
      t.binary  :file, :limit => (500 * 1024) # 500 kilobytes
      t.string  :content_type
      t.string  :creator_ip, :length => 20
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
