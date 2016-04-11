_ = require 'lodash'
BaseOptions = require './options'

class PostgresOptions extends BaseOptions

  ASC: 'ASC'
  DESC: 'DESC'

  rowOptions: (opts) ->
    rowOpts = {}
    unless isNaN opts.offset
      rowOpts.OFFSET = parseInt opts.offset
    unless isNaN opts.limit
      rowOpts.LIMIT = parseInt opts.limit
    return rowOpts

  sortOptions: (opts) =>
    orderings = @formatSortOpts opts
    sortOpts = {}
    if orderings? and orderings.length > 0
      sorts = orderings.map (order) -> order[0] + ' ' + order[1]
      sortOpts['ORDER BY'] = sorts.join ', '
    return sortOpts

  fieldOptions: (opts) ->
    fields = {}
    if opts.fields?
      fieldStr = opts.fields.join ', '
      fields.SELECT = fieldStr
    return fields

  tableOptions: (opts) ->
    if opts.table?
      return FROM: opts.table


module.exports = (new PostgresOptions).convertOptions
