#!/usr/bin/env ruby

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__) + "/.."))
require 'init'

describe Environment do
  behaves_like 'db_helper'
  
  before do
      reset_db
  end
  
  it "should return apps for environment" do
      myEnv = Environment.create(:name => 'testenv')
      myApp = App.create(:name => 'testapp')
      myAppVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv.add_appversion(myAppVersion)
      myEnv.apps.length.should == 1
      myEnv.apps[0][:name].should == 'testapp'
  end
end