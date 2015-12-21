_ = require 'lodash'

rowOptions = (opts) ->
  rowOpts = {}
  unless isNaN opts.offset
    rowOpts.skip = parseInt opts.offset
  unless isNaN opts.limit
    rowOpts.limit = parseInt opts.limit
  return rowOpts

sortValue = (v) ->
  if typeof v is 'string'
    v = v.toLowerCase()
  v = switch v
    when 1, '1', 'asc', 'ascending' then 1
    when -1, '-1', 'desc', 'descending' then -1
    else
      throw new Error 'Invalid field sort direction: ' + v
  return v

sortOptions = (opts) ->
  if opts.sort?
    if opts.sort instanceof Array
      orderings = opts.sort.map (s) ->
        [s[0], sortValue s[1]]
    else if opts.sort instanceof Object
      orderings = _.map opts.sort, (v, k) ->
        [k, sortValue v]
    else
      unless typeof opts.sort is 'string'
        msg = JSON.stringify opts.sort
      else
        msg = opts.sort
      throw new Error 'Invalid sort option format: ' + msg
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
