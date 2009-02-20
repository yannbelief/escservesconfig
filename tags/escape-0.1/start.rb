require 'rubygems'
gem 'ramaze', '>=2009.01'
require 'ramaze'

# Add directory start.rb is in to the load path, so you can run the app from
# any other working path
$LOAD_PATH.unshift(__DIR__)

# Initialize controllers and models
require 'model/init'
require 'controller/init'

#Ramaze.start :adapter => :mongrel, :port => 7000
Ramaze.start :adapter => :webrick, :port => 7000