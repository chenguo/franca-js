_ = require 'lodash'
common = require '../../common'
BaseOptions = require './options'

class PostgresOptions extends BaseOptions

  ASC: 'ASC'
  DESC: 'DESC'

  rowOptions: (opts) ->
    rowOpts = {}
    unless isNaN opts.offset
      rowOpts.offset = parseInt opts.offset
    unless isNaN opts.limit
      rowOpts.limit = parseInt opts.limit
    return rowOpts

  sortOptions: (opts) =>
    orderings = @formatSortOpts opts
    sortOpts = {}
    if orderings? and orderings.length > 0
      sorts = orderings.map (order) -> order[0] + ' ' + order[1]
      sortOpts.orderBy = sorts.join ', '
    return sortOpts

  fieldOptions: (opts) ->
    fields = {}
    if opts.fields?
      fieldStr = opts.fields.join ', '
      fields.select = fieldStr
    return fields

  tableOptions: (opts) ->
    if opts.table?
      return table: opts.table

  getPrimaryFields: (opts) ->
    primFields = opts.primaryField
    primFields = [primFields] unless _.isArray primFields
    unless primFields.every((f) -> _.isString(f) and not _.isEmpty(f))
      throw new Error "Postgres Primary Field(s) must be non-empty string"
    primFields

  multiRowOptions: (opts, q) ->
    if opts.singleRow and q? and common.isRegularWrite q
      primFields = @getPrimaryFields opts
      if primFields.length is 1
        return singleRowField: primFields[0]
      else
        throw new Error "Postgres single row field should and only should has one primary field"

module.exports = (new PostgresOptions).convertOptions
