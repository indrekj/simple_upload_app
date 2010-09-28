require "spec_helper"

describe AssetsController do
  render_views

  before(:all) do
    @html_file_path = File.dirname(__FILE__) + '/../files/jada.html'
    @jpeg_file_path = File.dirname(__FILE__) + '/../files/pic.jpg'
  end

  it "should show index page" do
    get :index
    response.should be_success
  end

  it "should show an asset" do
    asset = Factory.create(:asset, :file => uploaded_html(@html_file_path))
    get :show, :id => asset.id
    response.body.should match(/jada/)
  end

=begin
  TODO: New upload system changed much. Fix these later.
  it "should upload a file" do
    lambda {
      post :create, :asset => {:file => uploaded_html(@html_file_path), :title => 'title', :category_name => 'category'}
    }.should change(Asset, :count).by(1)
    response.should be_redirect
    flash[:notice].should_not be_blank

    Asset.last.body.should match(/jada/)
  end

  it "should not allow to upload image files" do
    lambda {
      post :create, :asset => {:file => uploaded_jpeg(@jpeg_file_path), :title => 'title', :category => 'category'}
    }.should_not change(Asset, :count)
    response.should be_success
    flash[:error].should_not be_blank
  end

  it "should not upload when file is not specified" do
    lambda {
      post :create, :asset => {:title => 'title', :category => 'category'}
    }.should_not change(Asset, :count)
    response.should be_success
    flash[:error].should_not be_blank
  end
=end
end
