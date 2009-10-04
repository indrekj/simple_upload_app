require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Link do
  it 'should not allow to add a description over 80 chars' do
    str = 'ten chars ' * 10 # 100 chars
    link = create_link(:description => str)
    link.description.length.should == 80
  end
end
