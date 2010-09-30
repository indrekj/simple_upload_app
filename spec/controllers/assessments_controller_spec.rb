require "spec_helper"

describe AssessmentsController do
  render_views

  before(:all) do
    @html_file_path = File.dirname(__FILE__) + '/../files/jada.html'
    @jpeg_file_path = File.dirname(__FILE__) + '/../files/pic.jpg'
  end

  it "should show index page" do
    get :index
    response.should be_success
  end

  it "should show an assessment" do
    assessment = Factory.create(:assessment, :file => uploaded_html(@html_file_path))
    get :show, :id => assessment.id
    response.body.should match(/jada/)
  end

  it "should upload a file" do
    lambda {
      post :create, :file => uploaded_html(@html_file_path)
    }.should change(Assessment, :count).by(1)

    assessment = Assessment.order("id ASC").last
    assessment.body.should match(/jada/)
    assessment.confirmed.should be_false
  end

  it "should not allow to upload image files" do
    lambda {
      post :create, :file => uploaded_jpeg(@jpeg_file_path)
    }.should_not change(Assessment, :count)
  end

  it "should not upload when file is not specified" do
    lambda {
      post :create
    }.should_not change(Assessment, :count)
  end
end
