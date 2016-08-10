_ = require 'lodash'
common = require '../../common'

class BaseWrite

  TYPES: common.TYPES

  notImplemented: (name) ->
    throw new Error "#{name} not implemented in Write Component"

  convertWrite: (writes) =>
    writes = common.objectify writes
    @buildWrite writes

  buildWrite: (writes) ->
    if common.isRegularWrite writes
      @buildSimple writes
    else if common.isRawWrite writes
      @buildRaw writes
    else
      throw new Error "Invalid Write Type: #{writes.type}"

  buildRaw: (writes) ->
    rawQuery = writes.raw
    if common.isInsert writes, 'raw'
      @buildRawInsertImpl writes, rawQuery
    else if common.isUpdate writes, 'raw'
      @buildRawUpdateImpl writes, rawQuery
    else if common.isUpsert writes, 'raw'
      @buildRawUpsertImpl writes, rawQuery
    else if common.isRemove writes, 'raw'
      @buildRawRemoveImpl writes, rawQuery

  buildRawInsertImpl: (writes, rawInsert) ->
    @notImplemented 'buildRawInsertImpl'

  buildRawUpdateImpl: (writes, rawUpdate) ->
    @notImplemented 'buildRawUpdateImpl'

  buildRawUpsertImpl: (writes, rawUpsert) ->
    @notImplemented 'buildRawUpsertImpl'

  buildRawRemoveImpl: (writes, rawRemove) ->
    @notImplemented 'buildRawRemoveImpl'

  buildSimple: (writes) ->
    writeQuery = writes.write
    if common.isInsert writes, 'regular'
      @buildInsert writes, writeQuery
    else if common.isUpdate writes, 'regular'
      @buildUpdate writes, writeQuery
    else if common.isUpsert writes, 'regular'
      @buildUpsert writes, writeQuery
    else if common.isRemove writes, 'regular'
      @buildRemove writes, writeQuery

  buildInsert: (writes, insertQuery) ->
    unless _.isArray insertQuery
      insertQuery = [insertQuery]
      writes.write = insertQuery
    @buildInsertImpl writes, insertQuery

  buildUpdate: (writes, updateQuery) ->
    @buildUpdateImpl writes, updateQuery

  buildUpsert: (writes, upsertQuery) ->
    @buildUpsertImpl writes, upsertQuery

  buildRemove: (writes, removeQuery) ->
    @buildRemoveImpl writes, removeQuery

  buildInsertImpl: (writes, insertQuery) ->
    @notImplemented 'buildInsertImpl'

  buildUpdateImpl: (writes, updateQuery) ->
    @notImplemented 'buildUpdateImpl'

  buildUpsertImpl: (writes, upsertQuery) ->
    @notImplemented 'buildUpsertImpl'

  buildRemoveImpl: (writes, removeQuery) ->
    @notImplemented 'buildRemoveImpl'

module.exports = BaseWrite
