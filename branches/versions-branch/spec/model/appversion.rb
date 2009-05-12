#!/usr/bin/env ruby

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__) + "/.."))
require 'init'

describe Appversion do
  behaves_like 'db_helper'
  
  before do
      reset_db
  end
  
  it "should add to default environment when created" do
    myApp = App.create(:name => 'testapp')
    Environment.default.appversions.length.should == 1 #default version
    Environment.default.appversions[0][:id].should == myApp.default_version()[:id]
  end
  
  it "should return all keys in child when no parent" do
    myApp = App.create(:name => 'testapp')
    myAppVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
    key = Key.create(:name => 'key', :appversion_id=>myAppVersion[:id])
    keys = myAppVersion.all_keys()
    keys.length.should == 1
    keys[0][:name].should == 'key'
  end
  
  it "should return keys from parent when parent exists" do
    myApp = App.create(:name => 'testapp')
    appVersion1 = Appversion.create(:name => '1.0', :app_id => myApp[:id])
    appVersion2 = Appversion.create(:name => '2.0', :parent_id => appVersion1[:id], :app_id => myApp[:id])
    appVersion2.parent[:id].should == appVersion1[:id]
    key = Key.create(:name => 'key', :appversion_id=>appVersion1[:id])
    appVersion2.keys.length.should == 0
    appVersion2.parent.all_keys().length.should == 1
    keys = appVersion2.all_keys()
    keys.length.should == 1
    keys[0][:name].should == 'key'
  end
  
  it "should return keys from child when parent exists and has the same key" do
     myApp = App.create(:name => 'testapp')
     appVersion1 = Appversion.create(:name => '1.0', :app_id => myApp[:id])
     appVersion2 = Appversion.create(:name => '2.0', :parent_id => appVersion1[:id], :app_id => myApp[:id])
     key = Key.create(:name => 'key', :appversion_id=>appVersion1[:id])
     keyInChild = Key.create(:name => 'key', :appversion_id=>appVersion2[:id])
     keys = appVersion2.all_keys()
     keys.length.should == 1
     keys[0][:id].should == keyInChild[:id]
  end
  
  it "should find key by name" do
     myApp = App.create(:name => 'testapp')
     appVersion1 = Appversion.create(:name => '1.0', :app_id => myApp[:id])
     appVersion2 = Appversion.create(:name => '2.0', :parent_id => appVersion1[:id], :app_id => myApp[:id])
     appVersion2.parent[:id].should == appVersion1[:id]
     key = Key.create(:name => 'key', :appversion_id=>appVersion1[:id])
     appVersion2.keys.length.should == 0
     appVersion2.find_key('key')[:name].should == 'key'
  end
  
  it "should return if version exists only in env" do
    myApp = App.create(:name => 'testapp')
    appVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
    appVersion.only_exists_in(Environment.default).should == true
    myEnv = Environment.create(:name => 'testenv')
    myEnv.add_appversion(appVersion)
    appVersion.only_exists_in(myEnv).should == false
  end
  
  it "should return true if child versions exist" do
     myApp = App.create(:name => 'testapp')
     appVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
     appVersion2 = Appversion.create(:name => '2.0', :parent_id => appVersion[:id], :app_id => myApp[:id])
     appVersion.has_child_versions?.should == true
     appVersion2.has_child_versions?.should == false
  end
  
  it "should delete version and its app after removing from default env, if it only exists there" do
    appName = 'testapp'
    myApp = App.create(:name => appName)
    appVersion = myApp.default_version()
    appVersion.delete_from_environment(Environment.default).should == true
    Appversion[:name => '1.0', :app_id => myApp[:id]].nil?.should == true
    App[:name => appName].nil?.should == true
  end
  
  it "should delete version after removing from default env since it only exists there, but keep the app since there are other versions" do
    appName = 'testapp'
    myApp = App.create(:name => appName)
    appVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
    appVersion2 = Appversion.create(:name => '2.0', :parent_id => myApp.default_version()[:id], :app_id => myApp[:id])
    appVersion.delete_from_environment(Environment.default).should == true
    Appversion[:name => '1.0', :app_id => myApp[:id]].nil?.should == true
    App[:name => appName].nil?.should == false
  end
  
  it "should not delete version from default env, if it exists in a different env" do
     myApp = App.create(:name => 'testapp')
     appVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
     myEnv = Environment.create(:name => 'testenv')
     myEnv.add_appversion(appVersion)
     appVersion.delete_from_environment(Environment.default).should == false
     Appversion[:name => '1.0', :app_id => myApp[:id]].nil?.should == false
   end
   
   it "should delete version from non-default env, if it has no child versions" do
      myApp = App.create(:name => 'testapp')
      appVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv = Environment.create(:name => 'testenv')
      myEnv.add_appversion(appVersion)
      myEnv.appversions.size.should == 1
      appVersion.delete_from_environment(myEnv).should == true
      myEnv.appversions.size.should == 0
    end
    
    it "should not delete version from non-default env, if there are child versions" do
        myApp = App.create(:name => 'testapp')
        appVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
        appVersion2 = Appversion.create(:name => '2.0', :parent_id => appVersion[:id], :app_id => myApp[:id])
        myEnv = Environment.create(:name => 'testenv')
        myEnv.add_appversion(appVersion)
        myEnv.appversions.size.should == 1
        appVersion.delete_from_environment(myEnv).should == false
        myEnv.appversions.size.should == 1
    end
    
    it "should return false if key has a value only in a default environment" do
      myApp = App.create(:name => 'testapp')
      appVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv = Environment.create(:name => 'testenv')
      myEnv.add_appversion(appVersion)
      key = Key.create(:name => 'key', :appversion_id=>appVersion[:id])
      appVersion.key_has_non_default_value(key).should == false
      Value.create(:key_id => key[:id], :appversion_id=>appVersion[:id], :environment_id => Environment.default[:id], :value=>'defaultvalue')
      appVersion.key_has_non_default_value(key).should == false
    end
    
    it "should return true if key has a value in a non-default environment" do
      myApp = App.create(:name => 'testapp')
      appVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv = Environment.create(:name => 'testenv')
      myEnv.add_appversion(appVersion)
      key = Key.create(:name => 'key', :appversion_id=>appVersion[:id])
      Value.create(:key_id => key[:id], :appversion_id=>appVersion[:id], :environment_id => myEnv[:id], :value=>'value')
      appVersion.key_has_non_default_value(key).should == true
    end
    
    it "should delete key and value in default env, if key only has a value in default env" do
      keyName = 'key'
      myApp = App.create(:name => 'testapp')
      appVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv = Environment.create(:name => 'testenv')
      myEnv.add_appversion(appVersion)
      key = Key.create(:name => keyName, :appversion_id=>appVersion[:id])
      appVersion.key_has_non_default_value(key).should == false
      Value.create(:key_id => key[:id], :appversion_id=>appVersion[:id], :environment_id => Environment.default[:id], :value=>'defaultvalue')
      appVersion.key_has_non_default_value(key).should == false
      appVersion.delete_key_value(key, Environment.default).should == true
      Value[:key_id => key[:id], :appversion_id=>appVersion[:id], :environment_id => Environment.default[:id]].nil?.should == true
      Key[:name => keyName, :appversion_id=>appVersion[:id]].nil?.should == true
    end
    
    it "should not delete key or value in default env, if key has a value in another non-default env" do
      keyName = 'key'
      myApp = App.create(:name => 'testapp')
      appVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv = Environment.create(:name => 'testenv')
      myEnv.add_appversion(appVersion)
      key = Key.create(:name => keyName, :appversion_id=>appVersion[:id])
      Value.create(:key_id => key[:id], :appversion_id=>appVersion[:id], :environment_id => Environment.default[:id], :value=>'defaultvalue')
      Value.create(:key_id => key[:id], :appversion_id=>appVersion[:id], :environment_id => myEnv[:id], :value=>'value')
      appVersion.delete_key_value(key, Environment.default).should == false
      Value[:key_id => key[:id], :appversion_id=>appVersion[:id], :environment_id => Environment.default[:id]].nil?.should == false
      Key[:name => keyName, :appversion_id=>appVersion[:id]].nil?.should == false
    end
    
    it "should delete value for key in a non-default env" do
      keyName = 'key'
      myApp = App.create(:name => 'testapp')
      appVersion = Appversion.create(:name => '1.0', :app_id => myApp[:id])
      myEnv = Environment.create(:name => 'testenv')
      myEnv.add_appversion(appVersion)
      key = Key.create(:name => keyName, :appversion_id=>appVersion[:id])
      appVersion.key_has_non_default_value(key).should == false
      Value.create(:key_id => key[:id], :appversion_id=>appVersion[:id], :environment_id => Environment.default[:id], :value=>'defaultvalue')
      Value.create(:key_id => key[:id], :appversion_id=>appVersion[:id], :environment_id => myEnv[:id], :value=>'value')
      appVersion.delete_key_value(key, myEnv).should == true
      Value[:key_id => key[:id], :appversion_id=>appVersion[:id], :environment_id => myEnv[:id]].nil?.should == true
      Value[:key_id => key[:id], :appversion_id=>appVersion[:id], :environment_id => Environment.default[:id]].nil?.should == false
      Key[:name => keyName, :appversion_id=>appVersion[:id]].nil?.should == false
    end
    
end