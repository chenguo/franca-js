# Write Operations

This is a preliminary spec on how to represent insert / update operations in a Franca query object.

## Table of Contents
* [Insert](#insert)
* [Update](#update)

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
    "field": "field1"
    "match": "baz"
  },
  "update": { }
}
```

The details of the update subkey is still under consideration


## Upsert

An upsert operation attempts to update data rows, and when it does not find matching rows to update it will insert the document.

```json
{
  "table": "example-table",
  "query": {
    "field": "field1"
    "match": "baz"
  },
  "update": { }
  "upsert": true
}
```

For upserts, the query field is not needed when the backend is a relational database. For Mongo, it may be optional depending on the contents of the ```update``` payload. This is still under consideration.
