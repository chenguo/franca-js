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

fieldOptions = (opts) ->
  if opts.fields? and opts.fields instanceof Array
    fieldOpts = _.reduce opts.fields, (fields, f) ->
      fields[f] = 1
      return fields
    , {}
    return fields: fieldOpts

toMongo = (opts) ->
  rowOpts = rowOptions opts
  sortOpts = sortOptions opts
  fieldOpts = fieldOptions opts
  mongoOpts = _.merge rowOpts, sortOpts, fieldOpts
  return mongoOpts

module.exports =
  toMongo: toMongo
