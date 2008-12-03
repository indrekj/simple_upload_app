require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a file exists" do
  request(resource(:files), :method => "POST", 
    :params => { :file => { :id => nil }})
end

describe "resource(:files)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:files))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of files" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a file exists" do
    before(:each) do
      @response = request(resource(:files))
    end
    
    it "has a list of files" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      @response = request(resource(:files), :method => "POST", 
        :params => { :file => { :id => nil }})
    end
    
    it "redirects to resource(:files)" do
    end
    
  end
end

describe "resource(@file)" do 
  describe "a successful DELETE", :given => "a file exists" do
     before(:each) do
       @response = request(resource(File.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:files))
     end

   end
end

describe "resource(:files, :new)" do
  before(:each) do
    @response = request(resource(:files, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@file, :edit)", :given => "a file exists" do
  before(:each) do
    @response = request(resource(File.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@file)", :given => "a file exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(File.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @file = File.first
      @response = request(resource(@file), :method => "PUT", 
        :params => { :file => {:id => @file.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@file))
    end
  end
  
end

