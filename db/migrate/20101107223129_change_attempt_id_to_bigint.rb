class ChangeAttemptIdToBigint < ActiveRecord::Migration
  def self.up
    change_column :assessments, :attempt_id, :bigint
  end

  def self.down
    change_column :assessments, :attempt_id, :integer
  end
end
