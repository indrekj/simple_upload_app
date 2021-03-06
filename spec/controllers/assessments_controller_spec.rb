require "spec_helper"

describe AssessmentsController do
  render_views

  before(:each) do
    @html_file_path = File.dirname(__FILE__) + '/../files/jada.html'
    @jpeg_file_path = File.dirname(__FILE__) + '/../files/pic.jpg'
  end

  it "should show index page" do
    get :index
    response.should be_success
  end

  it "should show an assessment" do
    assessment = Factory.create(:assessment, :test => uploaded_html(@html_file_path))
    get :show, :id => assessment.id
    response.body.should match(/jada/)
  end

  it "should upload a file" do
    expect {
      post :create, :file => uploaded_html(@html_file_path)
    }.to change(Assessment, :count).by(1)

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

  it "should check if assessment exists" do
    get :exists, :source => Assessment::Sources::MOODLE, :attempt_id => 4
    res = JSON.parse(response.body).symbolize_keys
    res[:exists].should be_false

    Factory.create(:assessment_with_test, 
      :source => Assessment::Sources::MOODLE, :attempt_id => 5
    )
    get :exists, :source => Assessment::Sources::MOODLE, :attempt_id => 5
    res = JSON.parse(response.body).symbolize_keys
    res[:exists].should be_true
  end
end
