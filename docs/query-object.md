# Query Object

The Franca query object is a common representation for basic data filters that most data resources provide. This object is intended to be translatable into native queries for supported backends.

Example:

```json
{
  "type": "Q",
  "field": "test-score",
  "range": {
    "min": 80,
    "max": 90
  }
}
```

For different data backends, this translates into different things. For Mongo, this translates into ```{$and: [{"test-score": {$gte: 80}}, {"test-score": {$lte: 90}}]}``` to be fed to a ```find()``` or ```update``` call. For Solr, this translates into ```test-score:[80 TO 90]``` to be added to a Solr query string.


## Query Types

The top-level ```type``` key determines how this query is handled.

```Q```: indicates this query is one of several types of standard queries. If no type is specified, the query defaults to this type.
```AND```, ```OR```: indicates a compound query, with nested subqueries
```RAW```: indicates a raw query that will be untouched during translation


### Standard Queries

Several types of standard queries are supported.


##### match

This is a value equality matching query. A ```field``` and a ```match``` key are required.

```json
{
  "type": "Q",
  "field": "name",
  "match": "Bill"
}
```
This translates into a query for rows where the field ```name``` is exactly "Bill".

Matching multiple values is also supported:
```json
{
  "type": "Q",
  "field": "name",
  "match": ["Bill", "Sally"]
}
```
This translates into a query for rows there the field ```name``` is exactly "Bill" or "Sally".

##### Null

This is a special match that matches empty fields.

```json
{
  "type": "Q",
  "field": "address",
  "null": true
}
```
This translates into a query for rows where the ```address``` field is empty. Semantically, for different databases this may mean different things. For instance, for Mongo we've decided this should match documents where ```address``` doesn't exist and documents where ```address``` has a ```null``` value.

##### Range

Range queries are for fields for which the underlying database supports a comparison based query, such as a greater than operation.

```json
{
  "type": "Q",
  "field": "rating",
  "range": {
    "min": 50,
    "max": 70
  }
}
```

The above translates into query for rows where the ```rating``` field falls between 50 and 70, inclusive.

A single bounding range can also be specified:
```json
{
  "type": "Q",
  "field": "rating",
  "range": {
    "min": 50
  }
}
```

##### Regex Match

Query a field with a regular expression.

```json
{
  "type": "Q",
  "field": "serial-number",
  "regexp": "/^\d{5}/"
}
```

The above translates into a query for the ```serial-number``` field where values start with five consecutive numbers.

Note that different data backends implement different regex engines. The officially accepted format is the Javascript regular expression format. In fact Javascript RegExp objects are acceptable under the ```regexp``` field.

The "/" characters surrounding the regular expression string is optional.
```json
{
  "type": "Q",
  "field": "serial-number",
  "regexp": "^\d{5}"
}
```

##### Full Text search

When a standard type query is given with no field specified and a ```text``` field, it is a free text query. At the moment, translation of free text queries are not supported.

##### Empty Queries

A standard query with non of the above supported keys is considered an empty query, matching everything. For example, for Mongo this is the ```{}``` query, and for Solr this is a ```*:*``` query.


### Compound Queries

Compound queries exist to support ```AND``` and ```OR``` conditionals for queries. A ```queries``` key is required, and should be an array of nested query objects. Nested query objects can also be compound queries, allowing arbitrarily complex conditional queries.

```json
{
  "type": "AND",
  "negate": true,
  "queries": [{
    "type": "Q",
    "field": "make",
    "match": "Nissan"
  }, {
    "type": "Q",
    "field": "model",
    "match": ["Altima", "Maxima"]
  }, {
    "type": "Q",
    "field": "year",
    "range": {
      "min": 2005,
      "max": 2009
    }
  }]
}
```


## Negating Queries

```Q```, ```AND```, and ```OR``` can be negated by adding a ```negate``` field and setting that to true.

The one exception is empty queries. Since they match anything, the negation would match nothing, and this action is both not useful and inconsistently supported by data backends.

```json
{
  "type": "AND",
  "negate": true,
  "queries": [{
    "type": "Q",
    "field": "make",
    "match": "Nissan"
  }, {
    "type": "Q",
    "field": "model",
    "match": "Maxima"
  }]
}
```