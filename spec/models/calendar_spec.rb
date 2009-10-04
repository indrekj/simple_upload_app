#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Calendar, 'fix time' do
  before do
    @calendar = Calendar.new
  end

  it 'should add a null to the end of the time' do
    @calendar.send(:fix_time, '14.3').should == '143000'
  end

  it 'should add a null to the start of the time' do
    @calendar.send(:fix_time, '8.15').should == '081500'
  end

  it 'should be valid time' do
    @calendar.send(:fix_time, '10.15').should == '101500'
  end
end
