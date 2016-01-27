# Query Object

The Franca query object is a common representation for basic data filters and ancillary options that most data resources provide. This object is intended to be translatable into native queries for supported backends.

## Table of Contents
* [Overview](#overview)
* [Data Filter](#query)
* [Query Options](#options)
* [Write Operations](#write)
* [Extensions](#extensions)

<a name="overview"/>
## Overview
Example:

```json
{
  "query": {
    "type": "Q",
    "field": "test-score",
    "range": {
      "gte": 80,
      "lte": 90
    }
  },
  "options": {
    "sort": {
      "test-score": "descending"
    }
  }
}
```

For different data backends, this translates into different things. For instance, this translates into the Solr query ```test-score:[80 TO 90]&sort=test-score desc``` which can be included in a Solr query string.

The query object has two main components:

**query** or **filter**: the logical filters for the query, which may include things like equality checks and and/or logic. For example, in SQL this is what's captured in the ```WHERE``` clause.

**options**: non-logical query options, such as the number of rows to skip or which columns to sort on.

If neither of the above keys are explicitly stated, the query object is assumed to be solely a logical query (i.e. what would go under the ```query``` subkey).

<a name="query"/>
## Data Filter

The ```query``` or ```filter``` subkey holds the core conditional logic for matching database rows, like looking for rows that match a specific value, a free text query, or even a raw query that is passed unprocessed to the data backend.

Please see [full query documentation](https://github.com/chenguo/franca-js/blob/master/docs/query-query.md).

<a name="options"/>
## Options

Options can be passed to a Franca query to denote things like how many rows to return and how to sort them. Support options:

* **table**: DB table against which query is made
* **fields**: columns to return in query
* **offset**: how many rows to skip in the list of returned results. Analagous to SQL's ```OFFSET```
* **limit**: the max number of rows to return. Analogous to SQL's ```LIMIT```
* **sort**: specify the field(s) to sort on. Can be specified in both array form and object form, similar to how Mongo's Node driver accepts sort options.

Please see [full options documentation](https://github.com/chenguo/franca-js/blob/master/docs/query-options.md).

<a name="write"/>
## Write operations

Write operations are currently being planned, and include generic insert and update operations. Please see [RFC](https://github.com/chenguo/franca-js/blob/master/docs/query-insert.md) here.

<a name="extensions"/>
## Extensions

Some databases support extra settings, and they can be either required or optional. For example, because of the way SQL queries are structured, Node drivers require the table to be a part of the query itself, thus Franca queries for the SQL family of data resources require a table member. Please see [the SQL extentions documentation](https://github.com/chenguo/franca-js/blob/master/docs/query-sql.md).
