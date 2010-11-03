class AddAttemptIdToAssessments < ActiveRecord::Migration
  def self.up
    add_column :assessments, :attempt_id, :integer
  end

  def self.down
    remove_column :assessments, :attempt_id
  end
end
