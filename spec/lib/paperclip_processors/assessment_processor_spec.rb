require "spec_helper"
require "paperclip_processors/assessment_processor"

describe AssessmentProcessor do
  describe "source determination" do
    it "should set the source to webct" do
      body = %!
      ...
      <script type="text/javascript">hideLinks()</script>
      <script type="text/javascript" src="/webct/libraryjs.dowebct></script>
      ...
      !
      AssessmentProcessor.determine_source(body).should == 
        Assessment::Sources::WEBCT
    end

    it "should set the source to moodle" do
      body = %!
        ...
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <link type="text/css" href="https://moodle.ut.ee/theme/standard/styles.php" />
        ...
      !
      AssessmentProcessor.determine_source(body).should == 
        Assessment::Sources::MOODLE
    end

    it "should set the source to unknown" do
      body = %!
        ...
        Some useless data
        ...
      !
      AssessmentProcessor.determine_source(body).should ==
        Assessment::Sources::UNKNOWN
    end
  end

  describe "removing delicate info" do
    describe "from moodle" do
      before(:each) do
        source = Assessment::Sources::MOODLE
        body = File.read(Rails.root.to_s + "/spec/files/moodle.htm")
        @body = AssessmentProcessor.remove_delicate_info(source, body)
      end

      it "should remove name" do
        @body.should_not include("John Doe")
      end

      it "should remove session keys" do
        @body.should_not include("sesskey")
      end

      it "should remove all form elements" do
        @body.should_not include("<form")
        @body.should_not include("</form>")
      end
    end
  end

  describe "determination of title and type" do
    describe "from moodle" do
      before(:all) do
        body = File.read(Rails.root.to_s + "/spec/files/moodle.htm")
        source = Assessment::Sources::MOODLE
        
        @title, @type = AssessmentProcessor.determine_title_and_type(source, body)
      end

      it "should detect the title" do
        @title.should == "Harjutustest 1"
      end

      it "should detect the category" do
        @type.should == "Funktsionaalprogrammeerimise meetod"
      end
    end

    describe "from webct" do
      before(:all) do
        body = File.read(Rails.root.to_s + "/spec/files/jada.html")
        source = Assessment::Sources::WEBCT
        
        @title, @type = AssessmentProcessor.determine_title_and_type(source, body)
      end

      it "should detect the title" do
        @title.should == "Jada- ja rööpvärat"
      end

      it "should not detect the category" do
        @type.should be_blank
      end
    end
  end
end
