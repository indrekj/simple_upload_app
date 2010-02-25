class AddConfirmedColumnToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :confirmed, :boolean, :default => false

    Asset.unconfirmed.update_all(["confirmed = ?", true])
  end

  def self.down
    remove_column :assets, :confirmed
  end
end
