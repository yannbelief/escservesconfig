#!/usr/bin/env ruby

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__) + "/.."))
require 'init'

describe Value do
  behaves_like 'db_helper'
  
  before do
      reset_db
  end
  
  it "should return true if names are same" do
    key1 = Key.create(:name => 'key')
    key2 = Key.create(:name => 'key')
    key1.sameAs(key2).should == true
    key3 = Key.create(:name => 'key1')
    key3.sameAs(key2).should == false
  end
  
end