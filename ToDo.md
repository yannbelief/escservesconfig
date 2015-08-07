# Features to come #

Escape is at alpha. These features will be incorporated before v1.0.

## Security ##

We are painfully aware that there is no security in Escape at v0.1. Our plans for v1.0 include:

  * Using PKI to encrypt sensitive values;
  * Using authentication to allow individuals and groups to 'own' environments and applications;
  * Access-controls to restrict the editing of un-owned values and environments.

## Databases ##

We're using Sequel in the backend. We use SQLite3 for development, but we're planning to do some basic testing with the following databases:

  * MySQL - tested - works
  * PostgresQL - tested - broken
  * Oracle - tested - need to work with Sequel to support auto incrementing primary keys to get it to work

## Version Tracking / Auditing ##

Need to at least have a trail that tells us who changed what when. Do we need the why as well?

## Client libraries ##

We haven't written a useful client library yet. But we would like to provide:

  * A DLL for .net applications, nAnt and MSBuild;
  * A jar for java applications and ant;
  * A client in a scripting language, like Python, Ruby, or Perl.
  * A client to do bulk transations on the escape database. (eg: I have moved my DB server from `fred` to `barney`, so I need to change all of my connection strings)

We're hoping though that the REST API is so easy to use you won't really worry about the client libraries anyway...