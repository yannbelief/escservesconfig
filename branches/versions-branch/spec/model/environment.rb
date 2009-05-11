#!/usr/bin/env ruby

require 'rubygems'
require 'ramaze'
require 'ramaze/spec/helper'

require __DIR__('../helper/db_helper')

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