_ = require 'lodash'
BaseWrite = require './base'

class MongoWrite extends BaseWrite

  buildRawInsertImpl: (writes, rawInsert) ->
    @buildMongoRawQuery rawInsert, 'Insert'

  buildRawUpdateImpl: (writes, rawUpdate) ->
    @buildMongoRawQuery rawUpdate, 'Update'

  buildRawUpsertImpl: (writes, rawUpsert) ->
    @buildMongoRawQuery rawUpsert, 'Upsert'

  buildRawRemoveImpl: (writes, rawRemove) ->
    @buildMongoRawQuery rawRemove, 'Remove'

  buildMongoRawQuery: (rawQuery, queryName) ->
    if 'string' is typeof rawQuery
      try
        raw = JSON.parse rawQuery
      catch e
        throw new Error "Failed parsing Mongo Raw #{queryName} string: #{e}"
    else if rawQuery instanceof Object
      raw = rawQuery
    unless raw?
      throw new Error "Mongo Raw #{queryName} isn't a valid JSON string or object: #{rawQuery}"
    raw

  buildInsertImpl: (writes, insertQuery) ->
    if insertQuery.every((insert) -> _.isObject insert)
      insertQuery
    else
      throw new Error "Invalid insert object: #{JSON.stringify insertQuery}"

  buildUpdateImpl: (writes, updateQuery) ->
    if _.isObject updateQuery
      return $set: updateQuery
    else
      throw new Error "Invalid update object: #{JSON.stringify updateQuery}"

  buildUpsertImpl: (writes, upsertQuery) ->
    @buildUpdate writes, upsertQuery

  buildRemoveImpl: (writes, removeQuery) ->

module.exports = (new MongoWrite).convertWrite
