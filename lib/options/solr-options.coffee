_ = require 'lodash'
common = require './common'


rowOptions = (opts) ->
  rowOpts = {}
  unless isNaN opts.offset
    rowOpts.start = parseInt opts.offset
  unless isNaN opts.limit
    rowOpts.rows = parseInt opts.limit
  return rowOpts

sortValue = common.makeSortValueFormatter 'asc', 'desc'

sortOptions = (opts) ->
  orderings = common.getSorts opts, sortValue
  if orderings? and orderings.length > 0
    sorts = orderings.map (order) -> order[0] + '+' + sortValue order[1]
    sortStr = sorts.join ','
    return sort: sortStr
  else
    return {}

toSolr = (opts) ->
  rowOpts = rowOptions opts
  sortOpts = sortOptions opts
  solrOpts = _.merge rowOpts, sortOpts
  return solrOpts

module.exports =
  toSolr: toSolr
