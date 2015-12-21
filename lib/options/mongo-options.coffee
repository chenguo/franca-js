_ = require 'lodash'
common = require './common'

rowOptions = (opts) ->
  rowOpts = {}
  unless isNaN opts.offset
    rowOpts.skip = parseInt opts.offset
  unless isNaN opts.limit
    rowOpts.limit = parseInt opts.limit
  return rowOpts

sortValue = common.makeSortValueFormatter 1, -1

sortOptions = (opts) ->
  orderings = common.getSorts opts, sortValue
  if orderings? and orderings.length > 0
    return sort: orderings
  else
    return {}

toMongo = (opts) ->
  rowOpts = rowOptions opts
  sortOpts = sortOptions opts
  mongoOpts = _.merge rowOpts, sortOpts
  return mongoOpts

module.exports =
  toMongo: toMongo
