require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessagesController do
  it "should return all messages" do
    get :index, :format => 'json'
    response.should be_success
    assigns(:messages).should == Message.all
  end

  it "should add a message" do
    lambda {
      post :create, :format => 'json', :message => {:author => 'John Doe', :body => 'This is a cool page'}
    }.should change(Message, :count)
    response.should be_success

    m = Message.last
    m.author.should == 'John Doe'
    m.body.should == 'This is a cool page'

    response.body.should == m.to_json
  end

  it "should not add a message when there is a validation error" do
    lambda {
      post :create, :format => 'json', :message => {:author => '', :body => 'This is a cool page'}
    }.should_not change(Message, :count)
    response.should be_success

    response.body.should match(/Nimi liiga/i)
  end

  it "should fetch a message" do
    message = create_message

    get :show, :id => message.id
    response.should be_success
    response.body.should == message.to_json
    assigns(:message).should == message
  end
end
