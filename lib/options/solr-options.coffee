DBOptions = require './db-options'

class SolrOptions extends DBOptions

  ASC: 'asc'
  DESC: 'desc'

  rowOptions: (opts) ->
    rowOpts = {}
    unless isNaN opts.offset
      rowOpts.start = parseInt opts.offset
    unless isNaN opts.limit
      rowOpts.rows = parseInt opts.limit
    return rowOpts

  sortOptions: (opts) =>
    orderings = @formatSortOpts opts
    if orderings? and orderings.length > 0
      sorts = orderings.map (order) => order[0] + '+' + order[1]
      sortStr = sorts.join ','
      return sort: sortStr

  fieldOptions: (opts) ->
    if opts.fields? and opts.fields instanceof Array
      return fl: opts.fields.join ','

solrOpts = new SolrOptions

module.exports =
  toSolr: solrOpts.convertOptions
