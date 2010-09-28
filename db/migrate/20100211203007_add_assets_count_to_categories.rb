class AddAssetsCountToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :assets_count, :integer, :default => 0

    Category.reset_column_information
    Category.all.each do |c|
      Category.update_counters(c.id, :assets_count => c.assessments.length)
    end
  end

  def self.down
    remove_column :categories, :assets_count
  end
end
