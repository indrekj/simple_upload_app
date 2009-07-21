require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LinksController do
  integrate_views

  it "should show index page" do
    get :index
    response.should be_success
  end

  it "should add a new link" do
    lambda {
      post :create, :link => {:url => 'http://google.com', :description => 'Best search engine'}
    }.should change(Link, :count).by(1)
    response.should be_redirect
    flash[:notice].should_not be_blank
  end

  it "should not add a link when there are validation errors" do
    lambda {
      post :create, :link => {:url => 'some_weird_url', :description => 'Description is ok'}
    }.should_not change(Link, :count)
    response.should be_success
    flash[:error].should_not be_blank
  end
end
