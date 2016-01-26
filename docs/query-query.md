# Core Query

This document describes the ```query``` key of a Franca query object.

## Table of Contents
* [Overview](#query-overview)
* [Standard](#query-standard)
  * [match](#query-type-match)
  * [null](#query-type-null)
  * [range](#query-type-range)
  * [regex](#query-type-regex)
  * [free text](#query-type-text)
  * [empty](#query-type-empty)
* [Compound](#query-compound)
* [Raw](#query-raw)
* [Negating Queries](#query-negation)



<a name="query-overview"/>
## Overview

The query subkey specifies the logical portion of the Franca query object. There are several types of queries as specified by the top-level ```type``` key, which determines how a query is handled.

* [Q](#query-standard): indicates this query is one of several types of standard queries
* [AND/OR](#query-compound): indicates a compound query, with nested subqueries
* [RAW](#query-raw): indicates a raw query that will be untouched during translation

By default, ```Q``` is assumed. All queries except ```RAW``` types can be [negated](#query-negation)

<a name="query-standard"/>
## Standard Queries

Several types of standard queries are supported.


<a name="query-type-match"/>
### match

This is a value equality matching query. A ```field``` and a ```match``` key are required.

```json
{
  "type": "Q",
  "field": "name",
  "match": "Bill"
}
```
This translates into a query for rows where the field ```name``` is exactly "Bill".

Matching multiple values is also supported:
```json
{
  "type": "Q",
  "field": "name",
  "match": ["Bill", "Sally"]
}
```
This translates into a query for rows there the field ```name``` is exactly "Bill" or "Sally".

<a name="query-type-null"/>
### Null

This is a special match that matches unset / non-existing fields.

```json
{
  "type": "Q",
  "field": "address",
  "null": true
}
```
This translates into a query for rows where the ```address``` field is empty. Semantically, for different databases this may mean different things. For instance, for Mongo we've decided this should match documents where ```address``` doesn't exist and documents where ```address``` has a ```null``` value.

You can also query for rows with existing values as follows:
```json
{
  "type": "Q",
  "field": "address",
  "null": false
}
```

<a name="query-type-range"/>
### Range

Range queries are for fields for which the underlying database supports a comparison based query, such as a greater than operation.

```json
{
  "type": "Q",
  "field": "rating",
  "range": {
    "gt": 50,
    "lte": 70
  }
}
```

The above translates into query for rows where the ```rating``` field has a value above 50 and less than or equal to 70.

A single-bound range can also be specified:
```json
{
  "type": "Q",
  "field": "rating",
  "range": {
    "gt": 50
  }
}
```

The bounds can be express with the following keys under the ```range``` subkey:

* **gt**: greater than
* **gte**: greater than or equal to
* **lt**: less than
* **lte**: less than or equal to

If both ```gt``` and ```gte``` or both ```lt``` and ```lte``` is specified, there is no guarantee of precedence and behavior is undefined.



### Regex Match
<a name="query-type-regex"/>
Query a field with a regular expression.

```json
{
  "type": "Q",
  "field": "serial-number",
  "regexp": "/^\d{5}/"
}
```

The above translates into a query for the ```serial-number``` field where values start with five consecutive numbers.

Note that different data backends implement different regex engines. The officially accepted format is the Javascript regular expression format. In fact Javascript RegExp objects are acceptable under the ```regexp``` field.

The "/" characters surrounding the regular expression string is optional.
```json
{
  "type": "Q",
  "field": "serial-number",
  "regexp": "^\d{5}"
}
```


<a name="query-type-text">
### Full Text search

When a standard type query is given with no field specified and a ```text``` field, it is a free text query. At the moment, translation of free text queries are not supported.

<a name="qeury-type-empty">
### Empty Queries

A standard query with non of the above supported keys is considered an empty query, matching everything. For example, for Mongo this is the ```{}``` query, and for Solr this is a ```*:*``` query.


<a name="query-compound"/>
## Compound Queries

Compound queries exist to support ```AND``` and ```OR``` conditionals for queries. A ```queries``` key is required, and should be an array of nested query objects. Nested query objects can also be compound queries, allowing arbitrarily complex conditional queries.

```json
{
  "type": "AND",
  "negate": true,
  "queries": [{
    "type": "Q",
    "field": "make",
    "match": "Nissan"
  }, {
    "type": "Q",
    "field": "model",
    "match": ["Altima", "Maxima"]
  }, {
    "type": "Q",
    "field": "year",
    "range": {
      "gte": 2005,
      "lte": 2009
    }
  }]
}
```

<a name="query-raw"/>
## Raw Queries

Raw queries can be passed to the data backed untouched by translation, for special features not explicitly supported by Franca.

Mongo example:

```json
{
  "type": "RAW",
  "raw": {
    "date": {
      "$type": 17
    }
  }
}
```

When translated into a Mongo query, the above query will filter for rows where date is a BSON Timestamp object.

<a name="query-negation"/>
## Negating Queries

```Q```, ```AND```, and ```OR``` can be negated by adding a ```negate``` field and setting that to true.

```json
{
  "type": "AND",
  "negate": true,
  "queries": [{
    "type": "Q",
    "field": "make",
    "match": "Nissan"
  }, {
    "type": "Q",
    "field": "model",
    "match": "Maxima"
  }]
}
```

The one exception is empty queries. Since they match anything, the negation would match nothing, and this action is both not useful and inconsistently supported by data backends.

