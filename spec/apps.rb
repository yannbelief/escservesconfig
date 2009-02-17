#!/usr/bin/env ruby

require 'rubygems'
require 'ramaze'
require 'ramaze/spec/helper'

require __DIR__('helper/db_helper')
require __DIR__('../start')

describe EnvironmentsController, 'Application bits' do
    behaves_like 'http', 'db_helper'
    ramaze  :view_root => __DIR__('../view'),
            :public_root => __DIR__('../public')

    before do
        reset_db
    end

    # App tests
    it 'should create an app on put /environments/default/appname' do
        got = put('/environments/default/appname')
        got.status.should == 201

        got = get('/environments/default')
        got.status.should == 200
        got.body.should.include "appname"
    end

    it 'should list apps in an environment' do
        got = put('/environments/default/appname')
        got.status.should == 201

        got = get('/environments/default')
        got.status.should == 200
        got.body.should.include "appname"
    end

    it 'should return 404 for non existing app' do
        got = get('/environments/default/badapp')
        got.status.should == 404
    end

    it 'should only list apps in the specified environment' do
        got = put('/environments/default/appname')
        got.status.should == 201

        got = put('/environments/myenv')
        got.status.should == 201

        got = put('/environments/myenv/myapp')
        got.status.should == 201

        got = get('/environments/myenv')
        got.status.should == 200
        got.body.should.not.include "appname"
        got.body.should.include "myapp"
    end

    it 'should always add new apps to the default environment' do
        got = put('/environments/default/appname')
        got.status.should == 201

        got = put('/environments/myenv')
        got.status.should == 201

        got = put('/environments/myenv/myapp')
        got.status.should == 201

        got = get('/environments/default')
        got.status.should == 200
        got.body.should.include "appname"
        got.body.should.include "myapp"
    end

    it 'should not allow apps to be created in non existing environments' do
        got = put('/environments/badenv/badapp')
        got.status.should == 404
    end

    it 'should only accept \A[.a-zA-Z0-9_-]+\Z as environment name' do
        got = put('/environments/default/spaced%20out%20name')
        got.status.should == 403
        
        got = put('/environments/default/Legal-app_name')
        got.status.should == 201

        got = put('/environments/default/still.legal')
        got.status.should == 201
    end
end
