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
  
  it "should copy an environment" do
     myEnv = Environment.create(:name => 'testenv')
     myApp = App.create(:name => 'testapp')
     myAppVersion = Appversion.create(:name => '1.0', :parent_id => myApp.default_version()[:id], :app_id => myApp[:id])
     myEnv.add_appversion(myAppVersion)
     key = Key.create(:name => 'key', :appversion_id=>myApp.default_version()[:id])
     Value.create(:key_id => key[:id], :appversion_id=>myAppVersion[:id], :environment_id => Environment.default[:id], :value=>'defaultvalue')
     Value.create(:key_id => key[:id], :appversion_id=>myAppVersion[:id], :environment_id => myEnv[:id], :value=>'value')
     keyValue = myApp.get_key_value(key, myAppVersion, myEnv)
     keyValue.value.should == 'value'
     myEnvCopy = myEnv.copy("copy")
     myEnvCopy.apps.length.should == 1
     myEnvCopy.apps[0][:name].should == 'testapp'
     keyValue = myApp.get_key_value(key, myAppVersion, myEnvCopy)
     keyValue.value.should == 'value'
  end
end