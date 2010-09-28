require "spec_helper"

describe Assessment do
  describe "source determination" do
    before(:each) do
      @assessment = Assessment.new
    end

    it "should set the source to webct" do
      @assessment.body = %!
      ...
      <script type="text/javascript">hideLinks()</script>
      <script type="text/javascript" src="/webct/libraryjs.dowebct></script>
      ...
      !
      @assessment.determine_source!
      @assessment.source.should == Assessment::Sources::WEBCT
    end

    it "should set the source to moodle" do
      @assessment.body = %!
        ...
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <link type="text/css" href="https://moodle.ut.ee/theme/standard/styles.php" />
        ...
      !
      @assessment.determine_source!
      @assessment.source.should == Assessment::Sources::MOODLE
    end

    it "should set the source to unknown" do
      @assessment.body = %!
        ...
        Some useless data
        ...
      !
      @assessment.determine_source!
      @assessment.source.should == Assessment::Sources::UNKNOWN
    end
  end

  describe "removing delicate info" do
    describe "from moodle" do
      before(:each) do
        @assessment = Assessment.new(:source => Assessment::Sources::MOODLE)
        @assessment.body = File.read(Rails.root.to_s + "/spec/files/moodle.htm")
        @assessment.remove_delicate_info!
      end

      it "should remove name" do
        @assessment.body.should_not include("John Doe")
      end

      it "should remove session keys" do
        @assessment.body.should_not include("sesskey")
      end

      it "should remove all form elements" do
        @assessment.body.should_not include("<form")
        @assessment.body.should_not include("</form>")
      end
    end
  end

  describe "determination of title and type" do
    describe "from moodle" do
      before(:all) do
        @assessment = Assessment.new
        @assessment.body = File.read(RAILS_ROOT + "/spec/files/moodle.htm")
        @assessment.determine_source!
        @assessment.source.should == Assessment::Sources::MOODLE
        
        @assessment.determine_type_and_title!
      end

      it "should detect the title" do
        @assessment.title.should == "Harjutustest 1"
      end

      it "should detect the category" do
        @assessment.category_name.should == "Funktsionaalprogrammeerimise meetod"
      end
    end

    describe "from webct" do
      before(:all) do
        @assessment = Assessment.new
        @assessment.body = File.read(RAILS_ROOT + "/spec/files/jada.html")
        @assessment.determine_source!
        @assessment.source.should == Assessment::Sources::WEBCT
        
        @assessment.determine_type_and_title!
      end

      it "should detect the title" do
        @assessment.title.should == "Jada- ja rööpvärat"
      end

      it "should not detect the category" do
        @assessment.category_name.should be_blank
      end
    end
  end
end
