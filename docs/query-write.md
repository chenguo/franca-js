# Write Operations

This is a preliminary spec on how to represent insert / update / upsert / remove operations in a Franca query object.


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
  "type": "INSERT",
  "table": "example-table",
  "write": {
    "field1": "foo",
    "field2": "bar"
  }
}
```
Or you can insert multi rows just by assigning an array to `write`:

```json
{
  "type": "INSERT",
  "table": "example-table",
  "write": [{
    "field1": "foo1",
    "field2": "bar1"
  }, {
    "field1": "foo2",
    "field2": "bar2",
    "field3": "test3"
  }]
}
```
Note that for SQL db like Postgres, if you insert multiple rows with different fields sets, Franca will do union on all the fields and the value of the field that doesn't exist in some rows will be set as `null`. For instance, the above write query will be translated to:

```sql
INSERT INTO example-table (field1, field2, field3) VALUES ('foo1', 'bar1', null), ('foo2', 'bar2', 'test3')
```

By specifying `RAW_INSERT` to `type` and the raw insert statement into `raw`, Franca won't translate the insert statement:

```json
{
  "type": "RAW_INSERT",
  "table": "example-table",
  "raw": "(field1, field2) VALUES ('foo1', 'bar1'), ('foo2', 'bar2')"
}
```
For PostgreSQL as example, the above Query Object will be translated to

```sql
INSERT INTO example-table (field1, field2) VALUES ('foo1', 'bar1'), ('foo2', 'bar2');
```


## Update

This operation applies update operations to existing rows in a data resource.

You need to specify the `query`, and put update data into `write`. Proposed format:

```json
{
  "type": "UPDATE",
  "table": "example-table",
  "query": {
    "field": "field1",
    "match": "baz"
  },
  "write": {
    "field2": "foo",
    "field3": "bar"
  }
}
```

Note that Update will only update the fields you specify, instead of replacing the entire row. Which means for Mongo, it implicitly adds the `$set` operator. If you want to update with the backend original intention, or use some special operators, you can specify a `RAW_UPSERT` to `type`, and Franca won't translate the query/write in `raw`:

```json
{
  "type": "RAW_UPDATE",
  "table": "example-table",
  "raw": {
    "query": {
      "field": "field1",
      "match": "baz"
    },
    "update": {
      "field2": "foo",
      "field3": "bar"
    }
  }
}
```
In Mongo, this will replace the entire row that matches `{"field1": "baz"}` with `{"field2": "foo", "field3": "bar"}`. And

```json
{
  "type": "RAW_UPDATE",
  "table": "example-table",
  "raw": {
    "query": {
      "field": "field1",
      "match": "baz"
    },
    "update": {
      "$unset": {
        "field2": "foo",
        "field3": "bar"
      }
    }
  }
}
```
will remove `field2` and `field3`.

By default update action will update all the matched rows(for Mongo which means implicitly setting `{"multi": true}`), but you can set `{"singleRow": true}` in `options` to update first matched row:

```json
{
  "type": "UPDATE",
  "table": "example-table",
  "query": {
    "field": "field1",
    "match": "baz"
  },
  "write": {
    "field2": "foo",
    "field3": "bar"
  },
  "options" : {
    "singleRow": true
  }
}
```
Note that in Postgres, default update action will update all matched rows. The only way to update first match is ordering the queried results and select the first one by unique key, so in Postgres you need to speicify an extra `options` `{"primaryField": "ID"}` explicitly, it will be translated to somthing like:

```sql
UPDATE example-table SET field2='foo', field3='bar' WHERE ID=(SELECT ID FROM example-table WHERE field1='baz' ORDER BY ID LIMIT 1)
```


## Upsert

Upsert is a little special. For Mongo, it attempts to update data rows that match a specific query, and inserts the document if it finds no matching rows. Which means the upsert action for Mongo is actually based on `query`, so you need to assign the query to `base` and update data to `write`:

```json
{
  "type": "UPSERT",
  "table": "example-table",
  "base": {
    "type": "AND",
    "queries": [{
        "field": "field1",
        "match": "foo1"
      },
      {
        "field": "field2",
        "match": "bar1"
      }]
  },
  "write": {
    "field2": "foo2",
    "field3": "test2"
  }
}
```

For relational database, like Postgres, it's actually based on Insert. It's an `INSERT ... ON CONFLICT ...` statement which implicitly requires `PRIMARY KEY` for conflict checking. The following Franca upsert query is for Postgres specifically, note that query object in `base` can only be an insert statement instead of a query one:

```json
{
  "type": "UPSERT",
  "table": "example-table",
  "base": {
    "field": "field1",
    "match": "baz"
  },
  "write": {
    "field2": "foo",
    "field3": "bar"
  }
}
```


The `{"type": "RAW_UPSERT"}` is also supported in case some special cases are needed, the statements in `raw` won't be translated:

```json
{
  "type": "RAW_UPSERT",
  "table": "example-table",
  "raw": {
    "query": {
      "field": "field1",
      "match": "baz"
    },
    "update": {
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
}
```


## Remove

The remove operation will delete rows from a data resource.

Proposed format:

```json
{
  "type": "REMOVE",
  "table": "example-table",
  "query": {
    "field1": "foo",
    "field2": "bar"
  }
}
```
Note that there's only `query` key instead of `write`, because either NoSQL or SQL database does remove action based on query. The above one will delete all rows that match `{"field1": "foo", "field2": "bar"}`.

Same with Update, the default action is deleting all matched rows, if you just want to delete the first matched row, just assign a `singleRow` flag:

```json
{
  "type": "REMOVE",
  "table": "example-table",
  "write": {
    "field1": "foo",
    "field2": "bar"
  },
  "options": {
    "singleRow": true
  }
}
```

