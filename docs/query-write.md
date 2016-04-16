# Write Operations

This is a preliminary spec on how to represent insert / update operations in a Franca query object.

## Table of Contents
* [Insert](#insert)
* [Update](#update)
* [Upsert](#upsert)
* [Remove](#remove)


## Insert

An insert operation can add a new row to a data resource.

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

This operation applies update operations to existing rows in a data resource.

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

By default update action will update all the matched rows(for Mongo which means implicitly setting `{"multi": true}`), but you can set `{"justOne": true}` in `options` to update first matched row:
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
    "justOne": true
  }
}
```
So in Postgres, if you speicify the `{"justOne": true}` explicitly, it will be translated to somthing like:
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


## Remove

The remove operation will delete rows from a data resource.

Proposed format:
```json
{
  "table": "example-table",
  "remove": {
    "field1": "foo",
    "field2": "bar"
  }
}
```
This will delete all rows that matched `{"field1": "foo", "field2": "bar"}`.
Same with Update, the default action is delete all matched rows, if you just want to delete first matched row, just assign a `justOne` flag:
```json
{
  "table": "example-table",
  "remove": {
    "field1": "foo",
    "field2": "bar"
  },
  "options": {
    "justOne": true
  }
}
```

