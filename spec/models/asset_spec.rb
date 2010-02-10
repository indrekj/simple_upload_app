require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
        @asset.body = File.read(RAILS_ROOT + "/spec/files/moodle.htm")
        @asset.remove_delicate_info!
      end

      it "should remove name" do
        @asset.body.should_not include("John Doe")
        puts @asset.body
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
end
