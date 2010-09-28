require "spec_helper"

describe Asset do
  describe "source determination" do
    before(:each) do
      @asset = Asset.new
    end

    it "should set the source to webct" do
      @asset.body = %!
      ...
      <script type="text/javascript">hideLinks()</script>
      <script type="text/javascript" src="/webct/libraryjs.dowebct></script>
      ...
      !
      @asset.determine_source!
      @asset.source.should == Asset::Sources::WEBCT
    end

    it "should set the source to moodle" do
      @asset.body = %!
        ...
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <link type="text/css" href="https://moodle.ut.ee/theme/standard/styles.php" />
        ...
      !
      @asset.determine_source!
      @asset.source.should == Asset::Sources::MOODLE
    end

    it "should set the source to unknown" do
      @asset.body = %!
        ...
        Some useless data
        ...
      !
      @asset.determine_source!
      @asset.source.should == Asset::Sources::UNKNOWN
    end
  end

  describe "removing delicate info" do
    describe "from moodle" do
      before(:each) do
        @asset = Asset.new(:source => Asset::Sources::MOODLE)
        @asset.body = File.read(Rails.root.to_s + "/spec/files/moodle.htm")
        @asset.remove_delicate_info!
      end

      it "should remove name" do
        @asset.body.should_not include("John Doe")
      end

      it "should remove session keys" do
        @asset.body.should_not include("sesskey")
      end

      it "should remove all form elements" do
        @asset.body.should_not include("<form")
        @asset.body.should_not include("</form>")
      end
    end
  end

  describe "determination of title and type" do
    describe "from moodle" do
      before(:all) do
        @asset = Asset.new
        @asset.body = File.read(RAILS_ROOT + "/spec/files/moodle.htm")
        @asset.determine_source!
        @asset.source.should == Asset::Sources::MOODLE
        
        @asset.determine_type_and_title!
      end

      it "should detect the title" do
        @asset.title.should == "Harjutustest 1"
      end

      it "should detect the category" do
        @asset.category_name.should == "Funktsionaalprogrammeerimise meetod"
      end
    end

    describe "from webct" do
      before(:all) do
        @asset = Asset.new
        @asset.body = File.read(RAILS_ROOT + "/spec/files/jada.html")
        @asset.determine_source!
        @asset.source.should == Asset::Sources::WEBCT
        
        @asset.determine_type_and_title!
      end

      it "should detect the title" do
        @asset.title.should == "Jada- ja rööpvärat"
      end

      it "should not detect the category" do
        @asset.category_name.should be_blank
      end
    end
  end
end
