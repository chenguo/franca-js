# Franca-JS

This is a library meant to make it easy to get and view data from different backends. Queries are encoded in a common JSON format that can be translated for use with different data backend sources, such as Mongo or Solr.

## Install

```
npm install franca-js
```

## Usage

Quick example for making a Solr query, assuming [solr-node-client](https://github.com/lbdremy/solr-node-client) is used.

```coffeescript
franca = require 'franca-js'
solrClient = require 'configured-solr-client' # initialized solr-node-client

# This can be generated on the UI or passed in from another module
queryObj =
  limit: 20
  query:
    field: 'age'
    match: gt: 21

solrQuery = franca.toSolr queryObj

# prints q=age:([21 TO *] NOT 21)&rows=20
console.log solrQuery

solrClient.get 'query', solrQuery, (err, resp) ->
  # handle GET response

```

## Overview

Franca queries are intended to be a common query format for the basic queries common to most data backends. Queries are separated into two parts, one being the core query which captures logic like ```and``` and ```or``` relationships, the other being the auxiliary options like number of rows to return. For SQL for instance, the core queries maps to the logic captured by the WHERE clause, while the auxiliary options would be everything else.

Of course, all data resources have their own quirks and special features, and no common query format can hope to capture all of these for each individual database. Franca queries support a raw mode that allow the user to pass a native query to the backend, exposing the full features of the underlying data resource.


## API

Top level Franca API documentation is located [here](https://github.com/chenguo/franca-js/blob/master/docs/api.md).

## Common Query Format

The common query format is a JSON object that incorporates basics data query logic. See full documentation [here](https://github.com/chenguo/franca-js/blob/master/docs/query-object.md).


## Query Parser

(TODO)

The query parser translates from a string (for example, from a user typing into an input box) into the common JSON format.
