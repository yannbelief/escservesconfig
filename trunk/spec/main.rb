#!/usr/bin/env ruby

require 'ramaze'
require 'ramaze/spec/helper'

require __DIR__('../start')

describe MainController do
    behaves_like 'http', 'xpath'
    ramaze  :view_root => __DIR__('../view'),
            :public_root => __DIR__('../public')

    it 'should show start page' do
        got = get('/')
        got.status.should == 200
        got.at('//title').text.strip.should == MainController.new.index
    end

    it 'should have /environments wired in' do
        got = get('/environments')
        got.status.should == 200
    end
end
