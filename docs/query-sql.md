# SQL Query Object Extensions

Translation to SQL based data backends support an extended set of configurations, some are required and some not.

## Table of Contents
* [Table](#sql-table)
* [Joins](#sql-joins)


<a name="table"/>
## Table

When translating to SQL, queries MUST include a table. This is because SQL based queries incorporate the target table into the query itself. On the other hand, this is optional for other databases like Mongo because in Mongo Node drivers typically getting a collection handle and making the query to the collection happens in separate steps.

Please see the [main query documentation](https://github.com/chenguo/franca-js/blob/master/docs/query-object.md#options-table) for more details.


<a name="join"/>

Support for SQL JOIN operations are planned.
