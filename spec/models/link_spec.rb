require "spec_helper"

describe Link do
  it 'should not allow to add a description over 80 chars' do
    Link.delete_all
    str = 'ten chars ' * 10 # 100 chars
    link = Factory.create(:link, :description => str)
    link.description.length.should == 80
  end
end
