# Installation Guide #

## System Requirements ##

First off - this a Ruby app. Development and testing is done with Ruby 1.8 on OSX. We test on Ubuntu from time to time as well, especially for the database integration.

In addition to Ruby 1.8, Escape also requires the following gems to run:

  * ramaze (= 2009.06.12)
  * rack (>= 1.0.0)
  * sequel (= 3.2.0)
  * sqlite
  * json
  * openssl

and these optional gems if you want to run the tests:

  * rack-test
  * bacon
  * Selenium
  * selenium-client


## Getting Escape ##

The best way to get Escape is to [download](http://code.google.com/p/escservesconfig/downloads/list) the zip file. Just unpack it where you want to keep it and go. If you have _rackup_ in your path, you can start the server with _ramaze start_. If not, _ruby start.rb_ should work.

Once the server is up, connect on port 7000 with your favourite browser.

If you don't feel like installing all the required gems, have a look at [RunningAsAWARFile](RunningAsAWARFile.md) for info on how to run as a .war under your favourite J2EE container.

## Alternate Databases ##

Escape is primarily developed and tested using SQLite3 as the database. We've also tested it (to a lesser extent) with the following:

  * [MySQL](http://www.mysql.com/)

To use one of these database, please edit the file _model/init.rb_ and follow the comments.

We would like to support the following databases but there are currently some issues with them:

  * Oracle - There is currently a bug in Sequel which prevents Oracle from working.
  * PostgreSQL - There's a bug somewhere (not sure if its us or Sequel).