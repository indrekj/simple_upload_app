class RenameAssetsToAssessments < ActiveRecord::Migration
  def self.up
    rename_table :assets, :assessments
    rename_column :categories, :assets_count, :assessments_count
  end

  def self.down
  end
end
