# Running as a .war file #

It's now possible to deploy Escape as a .war file. The API is fully working, but the UI is broken. We're working on it.

## Installation Steps ##

**Note:** This has been tested on Glassfish v3, Jetty and Apache Tomcat. For Jetty and Tomcat the war file must be expanded for this to work.

  1. Create an empty database for Escape in the RDBMS of your choice. Only MySQL ia tested and working so far. Sequel has issues with Postgres. Not tried any others.
  1. Create a user for your database that has admin access
  1. Create the .war by running _warbler_ in the source root directory
  1. Copy the esc-server.war file to the webapps directory of your container.
  1. Ensure the JDBC driver for your database is in the class path of your container.
  1. Create the file _~/.escape/config_ and put your JDBC connection string in there. Here's mine:

```
--- 
    jdbc.url: jdbc:mysql://localhost/escape?user=escape&password=escape

```

## Root Context ##

For the app to work correctly, it needs to be deployed to the root context of your container. Here's we'll explain how to do it (for the containers we've tested it on at least).

### Glassfish ###

Deploy the war file with the following command:

```
asadmin deploy --contextroot / escape.war
```


### Tomcat ###

  1. Rename your _webapps/ROOT_ directory to something else, or delete it
  1. Expand the escape.war file in to the _webapps/ROOT_ directory

### Jetty ###

Not had the time to try this yet. Someone please feel free to let me know how...