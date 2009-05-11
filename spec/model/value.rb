#!/usr/bin/env ruby

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__) + "/.."))
require 'init'

describe Value do
  behaves_like 'db_helper'
  
  before do
      reset_db
  end
  
  it "should return true if default" do
    myApp = App.create(:name => 'testapp')
    myAppVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
    Environment.default.add_appversion(myAppVersion)
    aKey = Key.create(:name => 'key', :appversion_id => myAppVersion[:id])
    value = Value.create(:key_id => aKey[:id], :appversion_id=>myAppVersion[:id], :environment_id => Environment.default[:id], :value => value, :is_encrypted => false)
    value.default?.should == true 
  end
  
  it "should return false if not default" do
    anEnv = Environment.create(:name => 'test')
    myApp = App.create(:name => 'testapp')
    myAppVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
    anEnv.add_appversion(myAppVersion)
    aKey = Key.create(:name => 'key', :appversion_id => myAppVersion[:id])
    value = Value.create(:key_id => aKey[:id], :appversion_id=>myAppVersion[:id], :environment_id => anEnv[:id], :value => value, :is_encrypted => false)
    value.default?.should == false 
  end
  
end
