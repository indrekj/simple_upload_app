class AddCategoryIdToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :category_id, :integer

    assets = Asset.find(:all, :select => "category")
    categories = assets.map(&:category).uniq

    categories.each do |cat|
      c = Category.create(:name => cat)
      Asset.update_all("category_id = #{c.id}", ["category = ?", cat])
    end

    remove_column :assets, :category
  end

  def self.down
    add_column :assets, :category, :string
    remove_column :assets, :category_id
  end
end
