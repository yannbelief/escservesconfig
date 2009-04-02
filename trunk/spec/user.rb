#!/usr/bin/env ruby

require 'rubygems'
require 'ramaze'
require 'ramaze/spec/helper'
require 'base64'
require 'json'

require __DIR__('helper/db_helper')
require __DIR__('../start')

describe UserController do
    behaves_like 'http', 'db_helper'

    ramaze  :view_root => __DIR__('../view'),
            :public_root => __DIR__('../public')

    before do
        reset_db
    end

    def encode_credentials(username, password)
        "Basic " + Base64.encode64("#{username}:#{password}")
    end

    it 'should return a 400 on GET /user' do
        got = get('/user')
        got.status.should == 400
    end

    it 'should return 404 for a user that does not exist' do
        got = get('/user/nothere')
        got.status.should == 404

        got = delete('/user/nothere')
        got.status.should == 404
    end

    it 'should get the details of an specified user on GET /user/name' do
        got = get('/user/nobody')
        got.status.should == 200
        data = JSON.parse(got.body)
        data["name"].should == "nobody"
        data["email"].should == "nobody@nowhere.com"
    end

    it 'should create a new user on POST /user/name' do
        email = "someone@somewhere.com"
        password = "somepassword"

        got = post('/user/somebody', {:email => email, :password => password})
        got.status.should == 201

        got = get('/user/somebody')
        got.status.should == 200
        data = JSON.parse(got.body)
        data["name"].should == "somebody"
        data["email"].should == email
    end

    it 'should bleat if email and/or password not specified' do
        got = post('/user/somebody', {:email => "email"})
        got.status.should == 403
        got.body.should.include? "password"

        got = post('/user/somebody', {:password => "password"})
        got.status.should == 403
        got.body.should.include? "email"
    end

    it 'should treat duplicate users as data updates' do
        got = post('/user/somebody', {:email => "email", :password => "password"})
        got.status.should == 201

        got = post('/user/somebody', {:email => "email", :password => "password"})
        got.status.should == 401
    end

    it 'should not be able to change user details unless authenticated as that user' do
        got = post('/user/somebody', {:email => "email", :password => "password"})
        got.status.should == 201

        got = post('/user/me', {:email => "me", :password => "me"})
        got.status.should == 201

        got = post('/user/somebody', {:password => "newpassword"})
        got.status.should == 401

        got = raw_mock_request(:post, '/user/somebody?password=newpassword', {'HTTP_AUTHORIZATION' => Base64.encode64("me:me")})
        got.status.should == 401

        got = raw_mock_request(:post, '/user/somebody?password=newpassword', {'HTTP_AUTHORIZATION' => Base64.encode64("somebody:password")})
        got.status.should == 200

        Owner[:name => "somebody"].password.should == MD5.hexdigest("newpassword")

        got = raw_mock_request(:post, '/user/somebody?email=newemail', {'HTTP_AUTHORIZATION' => Base64.encode64("somebody:newpassword")})
        got.status.should == 200

        Owner[:name => "somebody"].email.should == "newemail"
    end

    it 'should be able to delete a user when authenticated as that user' do
        got = post('/user/somebody', {:email => "email", :password => "password"})
        got.status.should == 201

        got = post('/user/me', {:email => "me", :password => "me"})
        got.status.should == 201

        got = delete('/user/somebody')
        got.status.should == 401

        got = raw_mock_request(:delete, '/user/somebody', {'HTTP_AUTHORIZATION' => Base64.encode64("me:me")})
        got.status.should == 401

        got = raw_mock_request(:delete, '/user/somebody', {'HTTP_AUTHORIZATION' => Base64.encode64("somebody:password")})
        got.status.should == 200

        got = get('/user/somebody')
        got.status.should == 404
    end
end