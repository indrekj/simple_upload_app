class IncreaseCategoriesNameLength < ActiveRecord::Migration
  def self.up
    change_column :categories, :name, :string, :limit => 80
  end

  def self.down
    change_column :categories, :name, :string, :limit => 50
  end
end
