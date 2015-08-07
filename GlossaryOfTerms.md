# Glossary #

## Application (app) ##

An application is a system that is under development. It can be of any architecture or language.

## Build Pipeline ##

A build pipeline is a series of automated, or semi-automated stages that code goes through between its creation and its deployment into production. A typical build pipeline is driven by a continuous integration server and involves a series of tests in a number of different environments.

## Environment (env) ##

An environment is a conceptual space where a single instance of an application runs. It is completely distinct from any other environment.

Environments could be as simple as a single desktop computer, or as complex as an entire production infrastructure that includes load-balancers, database servers, clusters of web servers _et al_. It is also possible for many environments to co-exist on a single piece of hardware.

## Environment-specific Configuration ##

Configuration refers to those application settings that can be altered to change the behaviour of a system, without having to change its code.

Environment-specific configuration consists _only_ of those items that change between environments. Eg: a connection string for a database in the 'test' environment would be different to the connection string used in the 'production' environment.

## Key ##

A key is an item that can take on a different value depending on the environment in which the application is running. It's much like a variable name.

Keys are atomic units of configuration. There is nothing smaller modeled in Escape.