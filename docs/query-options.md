# Query Options

This document describes the ```options``` key of a Franca query object.

## Table of Contents
* [Overview](#options-overview)
* [Common Option]
  * [table](#options-table)
* [Read Option]
  * [fields](#options-fields)
  * [offset](#options-offset)
  * [limit](#options-limit)
  * [sort](#options-sort)
* [Read Option]
  * [singleRow](#options-singlerow)
  * [primaryKey](#options-primarykey)


<a name="options-overview"/>
## Overview

The ```options``` key of a query is intended to cover the non-core-logic portion of a DB query.

There're 3 types of options, *common option* options can be used in any kind of query. *read option* options can be only used for reading operation(read query or facet), and *write option* options will only be effective on write operations(like insert, update and remove).

The follow option keys are supported:

***Common Option***:

* **table**: DB table against which query is made

***Read Option***:

* **fields**: columns to return in query
* **offset**: how many rows to skip in the list of returned results. Analagous to SQL's ```OFFSET```
* **limit**: the max number of rows to return. Analogous to SQL's ```LIMIT```
* **sort**: specify the field(s) to sort on. Can be specified in both array form and object form, similar to how Mongo's Node driver accepts sort options.

***Write Option***:

* **singleRow**: tell Franca if only take (write operation)effect on the first matched row, default is `false`.
* **primaryKey**: specify the primary key, this is usually just for SQL db. And currently for PostgreSQL, it is required when set the `singleRow: true` and do `upsert` operation, see also `query-write.md`.

- - -

## Common Option

<a name="options-table"/>
### Table

Specify a table to query; for example in SQL this would be a table, and in Mongo this would be a collection.

This is required for SQL because the table name is required as a part of the query itself, in the FROM clause. For other databases this is optional.

```json
{
  "options": {
    "table": "sandwiches",
    "fields": ["bread", "cheese"]
  }
}
```

The ```table``` key can also be specified as a top level key. The following is equivalent to the above:

```json
{
  "table": "sandwiches",
  "options": {
    "fields": ["bread", "cheese"]
  }
}
```

The above query would generate a query that selects the fields "bread" and "cheese" from a table called "sandwiches". In SQL this would be ```SELECT bread, cheese FROM sandwiches```.

## Read Option

<a name="options-fields"/>
### Fields / Columns

Specify the fields (columns)  to return in the query.

```json
{
  "options": {
    "fields": ["size", "price", "brand"]
  },
  "query": {
    "field": "category",
    "match": "soda"
  }
}
```

The above query only returns the ```size```, ```price```, and ```brand``` columns for rows where the ```category``` field has the value "soda".

<a name="options-offset"/>
### Offset

Specify the number of rows to skip from the query's result.

```json
{
  "options": {
    "offset": 100
  },
  "query": {
    "field": "name",
    "negate": true,
    "null": true
  }
}
```

The above query returns rows where the ```name``` field is not empty, starting from the 101st row found by the BD.

<a name="options-limit"/>
### Limit

Specify the maximum number of rows to return

```json
{
  "options": {
    "limit": 30
  },
  "query": {
    "field": "address",
    "regexp": "Main"
  }
}
```

The above query returns up to 30 rows where the ```address``` field contains the token "Main".

<a name="options-sort">
### Sort

THe sort option determines the order in which results are returned. This field can take both an object or an array.



```json
{
  "options": {
    "sort": [["height", 1], ["weight", -1]]
  }
}
```

```json
{
  "query": {},
  "options": {
    "sort": {
      "height": 1,
      "weight": -1
    }
  }
}

```

Both of the above queries returns all rows, sorted by height in ascending order and weight in descending order. WHen specified in the array format, the order in which sort logic is applied is maintained (i.e. "height" before "weight" in this exampe). When specified in the object format, application order is not guaranteed and is dependent on the underlying JS runtime's object key sort order.

The following values can be used to specify sort order (case insensitive):

* 1, "1", "asc", "ascending": ascending order
* -1, "-1", "desc", "descending": descending order

## Write Option

<a name="options-singlerow">
### Single Row

The singleRow option specifies if user wants to write against only the first matched row or not. The default is `false`.

```json
{
  "type": "UPDATE",
  "query": {},
  "write": {},
  "options": {
    "singleRow": true
  }
}
```

<a name="options-primarykey">
### Primary Field

The primaryField option is only for SQL database like Postgres, need to be specified when do Upsert and `singleRow` write(Update/Remove). String and array of strings(multiple fields consists of primary key) are both accepted.

```json
{
  "type": "REMOVE",
  "query": {},
  "options": {
    "primaryField": "ID"
  }
}
```
