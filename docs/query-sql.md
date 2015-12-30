# SQL Query Object Extensions

Translation to SQL based data backends support an extended set of configurations, some are required and some not.

## Table of Contents
* [Table](#sql-table)
* [Joins](#sql-joins)


<a name="table"/>
## Table

Node SQL drivers typically require the entire SQL string as input, which includes the table name. Thus when translating a Franca query object to a SQL based query, the user must specify the table, either in a top-level ```table``` key or nested within ```options``` as ```options.table```.

Examples:
```json
{
  "table": "sandwiches",
}
```

```json
{
  "options": {
    "table": "sandwiches"
  }
}
```

Both of the above would translate into ```SELECT * FROM sandwiches```



<a name="join"/>

Support for SQL JOIN operations are planned.
