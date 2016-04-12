# Write Operations

This is a preliminary spec on how to represent insert / update operations in a Franca query object.

## Table of Contents
* [Insert](#insert)
* [Update](#update)
* [Upsert](#upsert)

## Insert

An insert operation can add new row to a data resource.

Proposed format:
```json
{
  "table": "example-table",
  "insert": {
    "field1": "foo",
    "field2": "bar"
  }
}
```
Or you can insert multi rows just by assigning an array to `insert`:
```json
{
  "table": "example-table",
  "insert": [{
    "field1": "foo1",
    "field2": "bar1"
  }, {
    "field1": "foo2",
    "field2": "bar2"
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
    "field2": "foo",
    "field3": "bar"
  }
}
```

Note that `update` will only update the fields you specify, instead of replacing the entire row. Which means for Mongo, it implicitly adds the `$set` operator. If you want to update with the backend original intention, or use some special operators, you can specify a `RAW` to `type`, so that Franca won't translate your `update`:
```json
{
  "type": "RAW",
  "table": "example-table",
  "query": {
    "field": "field1",
    "match": "baz"
  },
  "update": {
    "field2": "foo",
    "field3": "bar"
  }
}
```
In Mongo, this will replace the entire row that matches `{"field1": "baz"}` with `{"field2": "foo", "field3": "bar"}`. And

```json
{
  "type": "RAW",
  "table": "example-table",
  "query": {
    "field": "field1",
    "match": "baz"
  },
  "update": {
    "$unset": {
      "field2": "",
      "field3": ""
    }
  }
}
```
will remove `field2` and `field3`.



Update will only update the first matched row by default, but you can set a `multi` key in `options` to update all matched rows:
```json
{
  "table": "example-table",
  "query": {
    "field": "field1",
    "match": "baz"
  },
  "update": {
    "field2": "foo",
    "field3": "bar"
  },
  "options" : {
    "multi": true
  }
}
```
So in Postgres, if you don't speicify the `multi`, it will be translated to somthing like:
```sql
UPDATE example-table SET field2='foo', field3='bar' WHERE ID=(SELECT ID FROM example-table WHERE field1='baz' ORDER BY ID LIMIT 1)
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
    "field2": "foo",
    "field3": "bar"
  }
}
```

For relational database, the query field is not needed, like Postgres, because it's actually an `INSERT ... ON CONFLICT ...` command which implicitly requires `PRIMARY KEY` in `upsert`. For NO_SQL database like Mongo, it may be optional depending on the contents of the ```upsert``` payload.


The `{"type": "RAW"}` is also supported in case some special cases are needed:

```json
{
  "type": "RAW",
  "table": "example-table",
  "query": {
    "field": "field1",
    "match": "baz"
  },
  "upsert": {
    "$set": {
      "field2": "boo",
      "field3": "bar"
    },
    "$setOnInsert": {
      "field1": "baz",
      "field2": "boo",
      "field3": "bar"
    }
  }
}
```
