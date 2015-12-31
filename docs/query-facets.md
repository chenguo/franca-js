# Query Facets

It is often useful to query a database for counts of values for a specific field. The immediate obvious application is to know counts after filtering for a particular value of a field.

## Table of Contents
* [Overview](#facet-overview)
* [Basic Facets](#facet-basic)
* [Facet Options](#facet-options)
* [Facets with Queries](#facet-queries)


<a name="facet-overview"/>
## Overview

Let's consider a database of fruit:

 fruit | color |
---|---
apple | red
grape | green
apple | green
apple | yellow
grape | purple
banana | yellow
strawberry | red


It is a common query to ask, how many rows are there for each color value? For the toy database above, the response would look like some form of

color | count
---|---
red | 2
green | 2
yellow | 2
purple| 1

Which tells the user if a filter of ```color == red``` is applied, they will get back two rows of data.

<a name="facet-basic"/>
## Basic Facets

An example Franca query that would be converted into a facet query:

```json
{
  "facet": {
    "field": "color"
  }
}
```

This will generate a query (aggregation pipeline for Mongo) that will return distinct values for the field ```color``` with counts associated with each value.


<a name="facet-options"/>
## Sorting Facets

The list of facets returned can be sorted. The default is to sort by facet count, in descending order.

```json
{
  "facet": {
    "field": "color",
    "sort": {
      "count": -1
    }
  }
}
```

It is also possible to sort by facet value and in ascending order via the ```facet.sort``` subkey. When specifying sorting by value, ascending is the default. The same values to specify sort direction for query options (1/-1, "asc"/"desc", "ascending"/"descending") can be used here.

**note**: because of Solr limitations, only descending count and ascending value facet ordering is available

facet.sort value | sorts by | order
---|---|---
null | count | descending
"count" | count | descending
"value" | value | ascending
-1 | count | descending
1 | count | ascending
"ascending" | count | ascending
```{"count": "asc"}``` | count | ascending
```{"value": 1}``` | value | ascending
```{"value": "desc"}``` | value | descending

For example, the following query will generate facets sorted by value, in ascending order.

```json
{
  "facet": {
    "field": "color",
    "sort": {
      "value": 1
    }
  }
}
```

<a name="facet-query"/>
## Facets with Query Filters

The facet operation is available in conjunction with a query. For example:

```json
{
  "facet": {
    "field": "color"
  },
  "query": {
    "field": "fruit",
    "match": "apple"
  }
}
```

This will first filter for fruits that are apples, then give you the color value counts on just apples. For the toy fruit database, the return would be some representation of:

color | count
---|---
red | 1
green | 1
yellow | 1

So the facet counting is only done for rows after the query has been applied. In SQL, this would be equivalent to ```SELECT color, COUNT(color) FROM fruits WHERE fruit = "apple" GROUP BY color ORDER BY COUNT(color) DESC```
