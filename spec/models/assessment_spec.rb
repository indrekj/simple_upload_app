require "spec_helper"

describe Assessment do
  describe "attempt_id validation" do
    before(:each) do
      Category.delete_all
      Assessment.delete_all
    end

    it "should allow blank" do
      3.times do
        Factory.create(:assessment_with_test,
          :source => Assessment::Sources::MOODLE, :attempt_id => nil
        )
      end
      3.times do
        Factory.create(:assessment_with_test,
          :source => Assessment::Sources::MOODLE, :attempt_id => ""
        )
      end
    end

    it "should allow same attempt id if the source is different" do
      Factory.create(:assessment_with_test,
        :source => Assessment::Sources::MOODLE, :attempt_id => 1
      )
      Factory.create(:assessment_with_test,
        :source => Assessment::Sources::WEBCT, :attempt_id => 1
      )
    end

    it "should not allow same attempt id twice when source is same" do
      Factory.create(:assessment_with_test,
        :source => Assessment::Sources::MOODLE, :attempt_id => 10
      )

      lambda {
        Factory.create(:assessment_with_test,
          :source => Assessment::Sources::MOODLE, :attempt_id => 10
        )
      }.should raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
