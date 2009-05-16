#!/usr/bin/env ruby

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
require 'init'

describe EnvironmentsController, 'With versioning' do
    behaves_like 'http', 'db_helper'
    ramaze  :view_root => __DIR__('../view'),
            :public_root => __DIR__('../public')

    def encode_credentials(username, password)
        "Basic " + Base64.encode64("#{username}:#{password}")
    end
    
    before do
        reset_db
        @me = Owner.create(:name => "me", :email => "me", :password => MD5.hexdigest("me"))
    end

    # App tests
    it 'should create an app with version 1.0 on put /environments/default/appname#1.0' do
        got = put('/environments/default/appname%231.0')
        got.status.should == 201

        got = get('/environments/default')
        got.status.should == 200
        got.body.should.include "appname"
    end
    
    it 'should list all versions for an app on get /versions/env/appname' do
        got = put('/environments/default/appname%231.0')
        got.status.should == 201

        got = get('/versions/default/appname')
        got.status.should == 200
        got.body.should == "[\"1.0\",\"default\"]"
    end
    
    it 'should be able to set a key value for a given app version in an environment' do
        got = put('/environments/default/appname%231.0')
        got.status.should == 201

        value = 'v1'
        got = put('/environments/default/appname%231.0/key1',  :input => value)
        got.status.should == 201
        
        got = get('/environments/default/appname%231.0')
        got.status.should == 200
        got.body.should.include "key1=v1"
    end
    
    it 'should be able to set a key value for a default app version in an environment' do
        got = put('/environments/default/appname%23default')
        got.status.should == 201

        value = 'v1'
        got = put('/environments/default/appname%23default/key1',  :input => value)
        got.status.should == 201
        
        got = get('/environments/default/appname%23default')
        got.status.should == 200
        got.body.should.include "key1=v1"
    end
    
    it 'should be update a key value for a given app version in an environment' do
        got = put('/environments/default/appname%231.0')
        got.status.should == 201

        value = 'v1'
        got = put('/environments/default/appname%231.0/key1',  :input => value)
        got.status.should == 201
        
        value = 'v1'
        got = put('/environments/default/appname%231.0/key1',  :input => 'updated')
        got.status.should == 200
        
        got = get('/environments/default/appname%231.0')
        got.status.should == 200
        got.body.should.include "key1=updated"
    end
    
    it 'should be able inherit a key value in child version, when it is set in the parent in an environment' do
        got = put('/environments/default/appname%231.0')
        got.status.should == 201

        value = 'v1'
        got = put('/environments/default/appname%231.0/key1',  :input => value)
        got.status.should == 201
        
        # create child 1.1 with parent 1.0
        got = put('/environments/default/appname%231.1',  :input => '1.0')
        got.status.should == 201
        
        got = get('/environments/default/appname%231.1')
        got.status.should == 200
        got.body.should.include "key1=v1"
    end
    
    it 'should be able override a key value in child version, when it is set in the parent in an environment' do
        got = put('/environments/default/appname%231.0')
        got.status.should == 201

        value = 'v1'
        got = put('/environments/default/appname%231.0/key1',  :input => value)
        got.status.should == 201
        
        # create child 1.1 with parent 1.0
        got = put('/environments/default/appname%231.1',  :input => '1.0')
        got.status.should == 201
        
        got = put('/environments/default/appname%231.1/key1',  :input => 'v2')
        got.status.should == 201
        
        got = get('/environments/default/appname%231.0')
        got.status.should == 200
        got.body.should.include "key1=v1"
          
        got = get('/environments/default/appname%231.1')
        got.status.should == 200
        got.body.should.include "key1=v2"
    end
    
    it 'should be able add a key for a child version only, and not have it show up in parent versions' do
        got = put('/environments/default/appname%231.0')
        got.status.should == 201

        value = 'v1'
        got = put('/environments/default/appname%231.0/key1',  :input => value)
        got.status.should == 201
        
        # create child 1.1 with parent 1.0
        got = put('/environments/default/appname%231.1',  :input => '1.0')
        got.status.should == 201
          
        got = put('/environments/default/appname%231.1/key2',  :input => 'v2')
        got.status.should == 201
        
        got = get('/environments/default/appname%231.1')
        got.status.should == 200
        got.body.should.include "key1=v1\nkey2=v2"
          
        got = get('/environments/default/appname%231.0')
        got.status.should == 200
        got.body.should.include "key1=v1"
        got.body.should.not.include "key2"
    end
    
    it 'should be able to delete a key value for a given app version in an environment' do
        got = put('/environments/default/appname%231.0')
        got.status.should == 201

        value = 'v1'
        got = put('/environments/default/appname%231.0/key1',  :input => value)
        got.status.should == 201
        
        got = delete('/environments/default/appname%231.0/key1')
        got.status.should == 200
        got.body.should.not.include "key1=v1"
    end
    
    it 'should delete app version 1.0 from the environment' do
        got = put('/environments/default/appname%231.0')
        got.status.should == 201

        got = get('/environments/default/appname%231.0')
        got.status.should == 200
        
        got = delete('/environments/default/appname%231.0')
        got.status.should == 200
        
        got = get('/environments/default/appname%231.0')
        got.status.should == 404
        
    end
    
    it 'should not be able to delete app version 1.0 from the environment, if it has child versions' do
        got = put('/environments/default/appname%231.0')
        got.status.should == 201

        got = get('/environments/default/appname%231.0')
        got.status.should == 200
        
        # create child 1.1 with parent 1.0
        got = put('/environments/default/appname%231.1',  :input => '1.0')
        got.status.should == 201
        
        got = delete('/environments/default/appname%231.0')
        got.status.should == 403
        
    end
    
    it 'should not delete app version 1.0 from default if it is used in other non-default envs' do   
        got = put('/environments/mine')
        got.status.should == 201
          
        got = raw_mock_request(:put, '/environments/mine/appname%231.0', 'HTTP_AUTHORIZATION' => encode_credentials("me", "me"))
        got.status.should == 201
        
        got = get('/environments/default/appname%231.0')
        got.status.should == 200
        
        got = delete('/environments/default/appname%231.0')
        got.status.should == 403
          
    end
    
end