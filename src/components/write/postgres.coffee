_ = require 'lodash'
BaseWrite = require './base'

class PostgresWrite extends BaseWrite

  pgValStringify: (val) ->
    if typeof val is 'string'
      val = "'#{val}'"
    else if val is undefined
      val = null
    "#{val}"

  buildRawInsertImpl: (writes, rawInsert) ->
    @buildPostgresRawQuery rawInsert, 'Insert'

  buildRawUpdateImpl: (writes, rawUpdate) ->
    @buildPostgresRawQuery rawUpdate, 'Update'

  buildRawUpsertImpl: (writes, rawUpsert) ->
    @buildPostgresRawQuery rawUpsert, 'Upsert'

  buildRawRemoveImpl: (writes, rawRemove) ->
    @buildPostgresRawQuery rawRemove, 'Remove'

  buildPostgresRawQuery: (rawQuery, queryName) ->
    if 'string' isnt typeof rawQuery
      throw new Error "Raw Postgres #{queryName} is not a string: #{rawQuery}"
    rawQuery

  buildInsertImpl: (writes, insertQuery) ->
    fieldsLists = insertQuery.map _.keys
    insertFields = _.union.apply _, fieldsLists
    insertValStrs = insertQuery.map (insert) =>
      valStr = insertFields
        .map((field) => @pgValStringify insert[field])
        .join ', '
      "(#{valStr})"
    insertValString = insertValStrs.join ', '
    insertFieldString = "(#{insertFields.join ', '})"
    "#{insertFieldString} VALUES #{insertValString}"

  buildUpdateImpl: (writes, updateQuery) ->
    fieldVals = _.map(updateQuery, (value, field) => "#{field} = #{@pgValStringify value}")
    fieldVals.join ', '

  # For simple query only,
  # like simple match or AND in UPSERT query
  translateSimpleQuery: (q) ->
    switch q.type
      when @TYPES.RAW, @TYPES.OR
        throw new Error "Simple Query only supports simple match or AND query"
      when @TYPES.AND
        if q.negate or q.queries.some((subQ) -> q.negate)
          throw new Error "Simple Query supports no negate query"
        andQueries = q.queries.map (subQ) => @translateSimpleQuery subQ
        return _.merge.apply _, andQueries
      else
        unless q.field? and q.match?
          throw new Error "Simple Query only supports match query"
        if _.isArray(q.match) and q.match.length > 1
          throw new Error "Simple Query only supports one single match query"
        singleQuery = {}
        matchVal = if _.isArray(q.match) then q.match[0] else q.match
        singleQuery[q.field] = matchVal
        return singleQuery

  buildUpsertImpl: (writes, upsertQuery) ->
    queryDoc = @translateSimpleQuery upsertQuery.query
    updateDoc = upsertQuery.update
    conflictFields = _.keys queryDoc
    intersectFields = _.intersection conflictFields, _.keys updateDoc
    if intersectFields.some((field) -> queryDoc[field] isnt updateDoc[field])
      throw new Error "Query and Update doc cannot have collided key/val in UPSERT"
    updateDoc = _.pick updateDoc, (value, field) ->
      not _.includes intersectFields, field
    insertStatement = @buildInsert writes, _.merge(queryDoc, updateDoc)
    updateStatement = @buildUpdate writes, updateDoc
    upsertStates =
      insert: insertStatement
      conflict: "(#{conflictFields.join ', '})"
      update: updateStatement

  buildRemoveImpl: (writes, removeQuery) -> ""

module.exports = (new PostgresWrite).convertWrite
