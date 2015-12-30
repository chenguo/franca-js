_ = require 'lodash'
common = require './common'


rowOptions = (opts) ->
  rowOpts = {}
  unless isNaN opts.offset
    rowOpts.OFFSET = parseInt opts.offset
  unless isNaN opts.limit
    rowOpts.LIMIT = parseInt opts.limit
  return rowOpts

sortValue = common.makeSortValueFormatter 'ASC', 'DESC'

sortOptions = (opts) ->
  orderings = common.getSorts opts, sortValue
  sortOpts = {}
  if orderings? and orderings.length > 0
    sorts = orderings.map (order) -> order[0] + ' ' + sortValue order[1]
    sortOpts['ORDER BY'] = sorts.join ', '
  return sortOpts

tableOptions = (opts) ->
  if opts.table?
    return FROM: opts.table
  else
    throw new Error 'No table specified'

joinOptions = (opts) ->
  # Not implemented
  return {}


toPg = (opts) ->
  rowOpts = rowOptions opts
  sortOpts = sortOptions opts
  joinOpts = joinOptions opts
  tableOpts = tableOptions opts
  combined = _.merge {}, rowOpts, sortOpts, tableOpts, joinOpts
  return combined

module.exports =
  toPg: toPg
