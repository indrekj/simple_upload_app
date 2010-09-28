class AddSourceColumnToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :source, :string, :limit => 20, :default => Assessments::Sources::UNKNOWN
  end

  def self.down
    remove_column :assets, :source
  end
end
