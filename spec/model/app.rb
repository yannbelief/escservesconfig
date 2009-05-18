#!/usr/bin/env ruby

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__) + "/.."))
require 'init'

describe App do
  behaves_like 'db_helper'
  
  before do
      reset_db
  end
  
  it "should create a default version when app is created" do
    myApp = App.create(:name => 'testapp')
    Appversion[:name => 'default', :app_id => myApp[:id]].nil?.should == false
  end
  
  it "should return json representation" do
    myApp = App.create(:name => 'testapp')
    appVersion1 = Appversion.create(:name => '1.0', :parent_id => myApp.default_version[:id], :app_id => myApp[:id])
    myApp.to_json.should == "[\"testapp\",[[\"default\",\"\"],[\"1.0\",\"default\"]]]"
  end
  
  it "should only return app versions in the given env" do
    myEnv = Environment.create(:name => 'testenv')
    myApp = App.create(:name => 'testapp')
    appVersion1 = Appversion.create(:name => '1.0', :parent_id => myApp.default_version[:id], :app_id => myApp[:id])
    appVersion2 = Appversion.create(:name => '2.0', :parent_id => myApp.default_version[:id], :app_id => myApp[:id])
    myEnv.add_appversion(appVersion1)
    myApp.versions_in_env(myEnv).should == [["1.0", "default"]]
  end
  
  it "create_version should create an app and app version with default version as parent, when app does not exist and parent is nil" do
    myEnv = Environment.create(:name => 'testenv')
    appName = 'appName'
    versionName = '1.0'
    App.create_version(appName, versionName, nil, myEnv)
    myApp = App[:name => appName]
    myApp.nil?.should == false
    myAppversion = Appversion[:name => versionName, :app_id => myApp[:id]]
    myAppversion.nil?.should == false
    myAppversion.parent[:id].should == myApp.default_version[:id]
    myEnv.appversions.length.should == 1
    myEnv.appversions[0][:id].should == myAppversion[:id]
  end
  
  it "create_version should create an app version with given version as parent" do
    myEnv = Environment.create(:name => 'testenv')
    appName = 'appName'
    versionName = '1.1'
    myApp = App.create(:name => appName)
    parentVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id], :parent_id => myApp.default_version()[:id]) 
    App.create_version(appName, versionName, parentVersion, myEnv)
    myAppversion = Appversion[:name => versionName, :app_id => myApp[:id]]
    myAppversion.nil?.should == false
    myAppversion.parent[:id].should == parentVersion[:id]
  end
   
  it "should return nil value if key does not exist" do
      myEnv = Environment.create(:name => 'testenv')
      myApp = App.create(:name => 'testapp')
      myAppVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv.add_appversion(myAppVersion)
      value = myApp.get_key_value(nil, myAppVersion, myEnv)
      value.nil?.should == true
  end
   
  it "should return value for key from default environment" do
     myEnv = Environment.create(:name => 'testenv')
     myApp = App.create(:name => 'testapp')
     myAppVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
     myEnv.add_appversion(myAppVersion)
     key = Key.create(:name => 'key', :appversion_id=>myAppVersion[:id])
     Value.create(:key_id => key[:id], :appversion_id=>myAppVersion[:id], :environment_id => Environment.default[:id], :value=>'defaultvalue')
     keyValue = myApp.get_key_value(key, myAppVersion, myEnv)
     keyValue.value.should == 'defaultvalue'
  end

  it "should return value for key from current environment" do
     myEnv = Environment.create(:name => 'testenv')
     myApp = App.create(:name => 'testapp')
     myAppVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
     myEnv.add_appversion(myAppVersion)
     key = Key.create(:name => 'key', :appversion_id=>myAppVersion[:id])
     Value.create(:key_id => key[:id], :appversion_id=>myAppVersion[:id], :environment_id => Environment.default[:id], :value=>'defaultvalue')
     Value.create(:key_id => key[:id], :appversion_id=>myAppVersion[:id], :environment_id => myEnv[:id], :value=>'value')
     keyValue = myApp.get_key_value(key, myAppVersion, myEnv)
     keyValue.value.should == 'value'
  end

  it "should return value for key from parent version" do
      myEnv = Environment.create(:name => 'testenv')
      myApp = App.create(:name => 'testapp')
      appVersion1 = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv.add_appversion(appVersion1)
      appVersion2 = Appversion.create(:name => '2.0', :parent_id => appVersion1[:id], :app_id => myApp[:id])
      myEnv.add_appversion(appVersion2)
      key = Key.create(:name => 'key', :appversion_id=>appVersion1[:id])
      Value.create(:key_id => key[:id], :appversion_id=>appVersion1[:id], :environment_id => Environment.default[:id], :value=>'defaultvalue')
      Value.create(:key_id => key[:id], :appversion_id=>appVersion1[:id], :environment_id => myEnv[:id], :value=>'valueinversion1')
      keyValue = myApp.get_key_value(key, appVersion2, myEnv)
      keyValue.value.should == 'valueinversion1'
   end
   
   it "should return all key values" do
       myEnv = Environment.create(:name => 'testenv')
       myApp = App.create(:name => 'testapp')
       appVersion1 = Appversion.create(:name => '1.0', :app_id => myApp[:id])
       myEnv.add_appversion(appVersion1)
       appVersion2 = Appversion.create(:name => '2.0', :parent_id => appVersion1[:id], :app_id => myApp[:id])
       myEnv.add_appversion(appVersion2)
       key = Key.create(:name => 'key', :appversion_id=>appVersion1[:id])
       Value.create(:key_id => key[:id], :appversion_id=>appVersion1[:id], :environment_id => Environment.default[:id], :value=>'defaultvalue')
       Value.create(:key_id => key[:id], :appversion_id=>appVersion1[:id], :environment_id => myEnv[:id], :value=>'valueinversion1')
       keyValues = myApp.all_key_values(appVersion2, myEnv)
       keyValues.length.should == 1
       keyValues[0].value.should == 'valueinversion1'
    end
    
   it "should add new key value in current and default environment" do
      myEnv = Environment.create(:name => 'testenv')
      myApp = App.create(:name => 'testapp')
      appVersion1 = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv.add_appversion(appVersion1)
      appVersion1.keys.length.should == 0
      added = myApp.set_key_value('key', appVersion1, myEnv, 'value', false)
      appVersion1.keys.length.should == 1
      added.should == true
      key = Key[:name => 'key', :appversion_id => appVersion1[:id]]
      Value[:key_id => key[:id], :appversion_id=>appVersion1[:id], :environment_id => myEnv[:id]][:value].should == 'value'
      Value[:key_id => key[:id], :appversion_id=>appVersion1[:id], :environment_id => Environment.default[:id]][:value].should == 'value'
    end

    it "should add value for existing key with nil value" do
      myEnv = Environment.create(:name => 'testenv')
      myApp = App.create(:name => 'testapp')
      appVersion1 = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv.add_appversion(appVersion1)
      key = Key.create(:name => 'key', :appversion_id => appVersion1[:id])
      added = myApp.set_key_value('key', appVersion1, myEnv, 'value', false)
      added.should == true
      appVersion1.keys.length.should == 1
      Value[:key_id => key[:id], :appversion_id=>appVersion1[:id], :environment_id => myEnv[:id]][:value].should == 'value'
    end

    it "should update value for existing key with non-nil value" do
      myEnv = Environment.create(:name => 'testenv')
      myApp = App.create(:name => 'testapp')
      appVersion1 = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv.add_appversion(appVersion1)
      key = Key.create(:name => 'key', :appversion_id=>appVersion1[:id])
      value = Value.create(:key_id => key[:id], :appversion_id=>appVersion1[:id], :environment_id => myEnv[:id], :value=>'oldvalue')
      added = myApp.set_key_value('key', appVersion1, myEnv, 'value', false)
      added.should == false
      appVersion1.keys.length.should == 1
      Value[:key_id => key[:id], :appversion_id=>appVersion1[:id], :environment_id => myEnv[:id]][:value].should == 'value'
    end
   
end
