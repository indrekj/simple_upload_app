class InitialMigration < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string  :title,    :length => 30
      t.string  :category, :length => 30
      t.string  :author,   :length => 30, :default => 'itimees'
      t.integer :year,     :length => 4
      t.text    :body
      t.string  :content_type
      t.string  :creator_ip, :length => 20
      t.timestamps
    end

    create_table :links do |t|
      t.string :url
      t.string :description
      t.string :creator_ip, :length => 20
      t.timestamps
    end

    create_table :messages do |t|
      t.string :body
      t.string :author
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
    drop_table :links
    drop_table :assets
  end
end
