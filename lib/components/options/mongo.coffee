_ = require 'lodash'
BaseOptions = require './options'

class MongoOptions extends BaseOptions

  ASC: 1
  DESC: -1

  rowOptions: (opts) ->
    rowOpts = {}
    unless isNaN opts.offset
      rowOpts.skip = parseInt opts.offset
    unless isNaN opts.limit
      rowOpts.limit = parseInt opts.limit
    return rowOpts

  sortOptions: (opts) =>
    orderings = @formatSortOpts  opts
    if orderings? and orderings.length > 0
      return sort: orderings
    else
      return {}

  fieldOptions: (opts) ->
    if opts.fields? and opts.fields instanceof Array
      fieldOpts = _.reduce opts.fields, (fields, f) ->
        fields[f] = 1
        return fields
      , {}
      return fields: fieldOpts


module.exports = (new MongoOptions).convertOptions

