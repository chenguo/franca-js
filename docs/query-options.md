# Query Options

This document describes the ```options``` key of a Franca query object.

## Table of Contents
* [Overview](#options-overview)
* [fields](#options-fields)
* [table](#options-table)
* [offset](#options-offset)
* [limit](#options-limit)
* [sort](#options-sort)


<a name="options-overview"/>
## Overview

The ```options``` key of a query is intended to cover the non-core-logic portion of a DB query. The follow option keys are supported:

* **table**: DB table against which query is made
* **fields**: columns to return in query
* **offset**: how many rows to skip in the list of returned results. Analagous to SQL's ```OFFSET```
* **limit**: the max number of rows to return. Analogous to SQL's ```LIMIT```
* **sort**: specify the field(s) to sort on. Can be specified in both array form and object form, similar to how Mongo's Node driver accepts sort options.

<a name="options-table"/>
## Table

Specify a table to query; for example in SQL this would be a table, and in Mongo this would be a collection.

This is required for SQL because the table name is required as a part of the query itself, in the FROM clause. For other databases this is optional.

```json
{
  "options": {
    "table": "sandwiches"
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

<a name="options-fields"/>
## Fields / Columns

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
## Offset

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
## Limit

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
## Sort

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
