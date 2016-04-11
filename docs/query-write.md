# Write Operations

This is a preliminary spec on how to represent insert / update operations in a Franca query object.

## Table of Contents
* [Insert](#insert)
* [Update](#update)
* [Upsert](#upsert)

## Insert

An insert operation adds new rows to a data resource.

Proposed format:
```json
{
  "table": "example-table",
  "insert": [{
    "field1": "foo"
  }, {
    "field1": "bar"
  }]
}
```


## Update

An update operation applies update operations to existing rows in a data resource.

Proposed format:
```json
{
  "table": "example-table",
  "query": {
    "field": "field1",
    "match": "baz"
  },
  "update": {
    "field2": "value2",
    "field3": "value3"
  }
}
```

For Mongo, the operators are also supported in `update` key, like `$set`, `$setOnInsert` and so on. In that case, the format may look like:
```json
{
  "table": "example-table",
  "query": {
    "field": "field1",
    "match": "baz"
  },
  "update": {
    "$set": {
      "field2": "value2",
      "field3": "value3"
    }
  }
}
```

Other than the particular operators of different databases, the behaviors may also different for different backends. Like Postgres will update all matched rows whereas Mongo doesn't. So the `options` key could solve this kind of problem. In Mongo, you can set `multi` to perform the same result:
```json
{
  "table": "example-table",
  "query": {
    "field": "field1",
    "match": "baz"
  },
  "update": {
    "field2": "value2",
    "field3": "value3"
  },
  "options" : {
    "multi": true
  }
}
```

## Upsert

An upsert operation attempts to update data rows, and when it does not find matching rows to update it will insert the document.

```json
{
  "table": "example-table",
  "query": {
    "field": "field1",
    "match": "baz"
  },
  "upsert": {
    "field2": "value2",
    "field3": "value3"
  }
}
```

For relational database, the query field is not needed, like Postgres, because it's actually an `INSERT ... ON CONFLICT ...` command which implicitly requires `PRIMARY KEY` in `upsert`. For NO_SQL database like Mongo, it may be optional depending on the contents of the ```upsert``` payload. This is still under consideration.
