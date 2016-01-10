# API

This document describes the top level Franca API available by requiring 'franca-js'.

## Table of Contents
* [TYPES](#franca-types)
* [translate](#franca-translate)
* [query](#franca-query)


<a name="franca-types"/>
## TYPES

```franca.TYPES``` holds the basic query types Franca internally uses. You can refer to this when constructing your queries.

TYPES holds the following types, whose values are the same as the type.

* ```TYPES.Q```: standard queries
* ```TYPES.AND```: for AND compound queries
* ```TYPES.OR```: for OR compound queries
* ```TYPES.RAW```: for RAW queries

<a name="franca-translate"/>
## translate

```franca.translate``` contains Franca's query translators. The following translators are available, each of which take a Franca query object.

* ```translate.toMongo```: translate to Mongo query
* ```translate.toPg```: translate to Postgres query
* ```translate.toSolr```: translate to Solr query

Ecah of the above ```to*``` functions are also available at the top level. I.e. ```franca.translate.toSolr``` is also available as ```franca.toSolr```.

<a name="franca-query"/>
## query

```franca.query``` is an in-memory Franca query evaluator. Two functions are available.

NOTE: franca.query implementation is currently in development, and is planned to be complete with version 0.5.0

### query.makePredicate(query)

Returns a predicate function, which takes a row of data and returns if the row matches the given query.

```coffee-script
fq = require('franca-js').query

query =
  query:
    field: 'country'
    match: 'South Africa'
predicate = fq.makePredicate query

# this will return false
isMatch = predicate country: 'Italy'

# this will return true
isMatch = predicate country: 'South Africa'
```

### query.queryData(rows, query)

Given rows of data and a Franca query, apply the query to rows of data and return the selected rows while respecting options like ```options.limit``` and ```options.offset```.
