# API

This document describes the top level Franca API available by requiring 'franca-js'.

## Table of Contents
* [query object](#franca-query)
* [TYPES](#franca-types)
* [translate](#franca-translate)
* [dataset](#franca-dataset)


<a name="franca-query"/>
## Query Objects

Franca-JS revolves around the Franca query object, which strives to be a common query format that can be translated into equivalent queries for a number of data backends.

The query object is fully documented [here](https://github.com/chenguo/franca-js/blob/master/docs/query-object.md).

<a name="franca-types"/>
## TYPES

```franca.TYPES``` holds the basic query types Franca internally uses. You can refer to this when constructing your queries.

TYPES holds the following types, whose values are the same as the type.

* ```TYPES.Q```: standard queries
* ```TYPES.AND```: for AND compound queries
* ```TYPES.OR```: for OR compound queries
* ```TYPES.RAW```: for RAW queries
* `TYPES.INSERT`: for regular INSERT operation request
* `TYPES.UPDATE`: for regular UPDATE operation request
* `TYPES.UPSERT`: for regular UPSERT operation request
* `TYPES.REMOVE`: for regular REMOVE operation request
* `TYPES.RAW_INSERT`: for RAW INSERT operation request
* `TYPES.RAW_UPDATE`: for RAW UPDATE operation request
* `TYPES.RAW_UPSERT`: for RAW UPSERT operation request
* `TYPES.RAW_REMOVE`: for RAW REMOVE operation request

<a name="franca-translate"/>
## translate

```franca.translate``` contains Franca's query translators. The following translators are available, each of which take a Franca query object.

* ```translate.toMongo```: translate to Mongo query
* ```translate.toPg```: translate to Postgres query
* ```translate.toSolr```: translate to Solr query

Ecah of the above ```to*``` functions are also available at the top level. I.e. ```franca.translate.toSolr``` is also available as ```franca.toSolr```.

### Translate Example

Example code:

```coffee-script
franca = require 'franca-js'

query =
  table: 'measurements'
  query:
    field: 'units'
    match: ['oz', 'mg', 'kg']
  options:
    limit: 3

mongoQuery = franca.toMongo query
console.log 'Mongo translation:'
console.log mongoQuery

postgresQuery = franca.toPg query
console.log '\nPostgres translation:'
console.log postgresQuery

solrQuery = franca.toSolr query
console.log '\nSolr translation:'
console.log solrQuery
```

The above would print:
```
Mongo translation:
{ query: { units: { '$in': [Object] } },
  options: { limit: 3 },
  collection: 'measurements' }

Postgres translation:
SELECT * FROM measurements WHERE units IN ('oz', 'mg', 'kg') LIMIT 3

Solr translation:
q=units:("oz" OR "mg" OR "kg")&rows=3
```


<a name="franca-dataset"/>
## dataset

```franca.dataset``` provide functions that operate on in-memory data. Essentially, this is Franca itself acting as a database.


### dataset.makePredicate(query)

Returns a predicate function, which takes a row of data and returns if the row matches the given query.

```coffee-script
ds = require('franca-js').dataset

query =
  query:
    field: 'country'
    match: 'South Africa'
predicate = ds.makePredicate query

# this will return false
isMatch = predicate country: 'Italy'

# this will return true
isMatch = predicate country: 'South Africa'
```

### dataset.query(rows, query)

Given rows of data and a Franca query, apply the query to rows of data and return the selected rows while respecting options like ```options.limit``` and ```options.offset```. Please see the [query documentation](https://github.com/chenguo/franca-js/blob/master/docs/query-object.md) for more details.

### dataset.facets(rows, facetQuery)

Given rows of data and a Franca facet query, return the available facets. See the [facets documentation](https://github.com/chenguo/franca-js/blob/master/docs/query-facets.md) for more details.
