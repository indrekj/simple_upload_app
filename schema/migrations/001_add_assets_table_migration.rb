class AddAssetsTableMigration < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string  :title, :length => 30
      t.string  :category, :length => 30
      t.string  :author, :default => 'itimees', :length => 30
      t.integer :year, :length => 4
      t.text    :body
      t.string  :content_type
      t.string  :creator_ip, :length => 20
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
