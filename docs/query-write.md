# Write Operations

This is a preliminary spec on how to represent insert / update / remove operations in a Franca query object.


## Table of Contents
* [Insert](#insert)
* [Update](#update)
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

By specifying a `RAW` type, and an action to `action_type`, Franca won't translate the insert statement:

```json
{
  "type": "RAW",
  "action_type": "ACTION_INSERT",
  "table": "example-table",
  "raw": "(field1, field2) VALUES ('foo1', 'bar1'), ('foo2', 'bar2')"
}
```
For PostgreSQL as example, the above Query Object will be translated to

```sql
INSERT INTO example-table (field1, field2) VALUES ('foo1', 'bar1'), ('foo2', 'bar2');
```


## Update

This operation applies update/upsert operations to existing rows in a data resource.

### Update Dedicated

You need to specify a query to `query`, and put update data into `write`. Proposed format:

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

Note that Update will only update the fields you specify, instead of replacing the entire row. Which means for Mongo, it implicitly adds the `$set` operator. If you want to update with the backend original intention, or use some special operators, you can specify a `RAW` type(as well as an action type), and Franca won't translate the query/write in `raw`:

```json
{
  "type": "RAW",
  "action_type": "ACTION_UPDATE",
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
In Mongo, this will replace the entire row that matches `{"field1": "baz"}` with the doc `{"field2": "foo", "field3": "bar"}`. And

```json
{
  "type": "RAW",
  "action_type": "ACTION_UPDATE",
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
Note that in Postgres, default update action will update all matched rows. The only way to update first match row is to sort the queried results and select the first one by unique key, so in Postgres you need to speicify an extra `options` `{"primaryField": "ID"}` explicitly, it will be translated to somthing like:

```sql
UPDATE example-table SET field2='foo', field3='bar' WHERE ID=(SELECT ID FROM example-table WHERE field1='baz' ORDER BY ID LIMIT 1)
```

### Upsert Dedicated

Update also covers the Upsert case, just by adding a dedicated pair of key/value: `upsert: true`. But there're some different among various databases.

For Mongo, it attempts to update data rows(with doc in `write`) that match a specific `query`, and inserts the document if it finds no matching rows. So you need to assign the query to `query` and update doc to `write`:

```json
{
  "type": "UPDATE",
  "table": "example-table",
  "upsert": true,
  "query": {
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

For relational database, like Postgres, the Upsert action is actually based on Insert, which is an `INSERT ... ON CONFLICT …` statement.

Semantically speaking, FrancaJS will

* treat the doc in `query` as the conflict target(fields in `ON CONFLICT ()`)
* if any conflict detected(means the conflict target values are the same), update with the doc in `write` 
* otherwise insert a doc that is th merge result of `query` and `write`.

Due to the natural limit of Postgres `upsert` action, we set 2 contraints on Postgres `upsert`:

* The `query` could only be i.) a single match query, or ii.) an `AND` compound `queries`, each sub query of which is a single match query. In other words, the `query` could be translated to a simple object that only contains keys(fields) and values, so you should not use type/keywords including but not limited to `RAW`, `OR`, `regex`, `facet`, `range` and so on.
* The translated `query`(simple k/v version) and `write` are not allowed having field that have collided value, like `{"query": {"foo": 1}, "write": {"foo": 2}}` is forbidened because `"foo"` has different values in `query` and `write`, but `{"query": {"foo": 1}, "write": {"foo": 1}}` is fine.

 The following Franca update query is for Postgres Upsert specifically:

```json
{
  "type": "UPDATE",
  "table": "example-table",
  "upsert": true,
  "query": {
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
    "field2": "bar1",  // Or this line could be omitted in favor of "query"
    "field3": "test2"
  }
}
```

The `RAW` type is also supported in case some special cases are needed, the statements in `raw` won't be translated:

```json
{
  "type": "RAW",
  "action_type": "ACTION_UPDATE",
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

The remove operation will delete rows from a data source.

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
  "query": {
    "field1": "foo",
    "field2": "bar"
  },
  "options": {
    "singleRow": true
  }
}
```

