common = require '../common'
makePredicate = require './make-predicate'

# Evaluator for Franca queries on in memory data

applyOptions = (rows, options) ->
  offset = options.offset or 0
  if options.limit
    rows = rows.slice offset, offset + options.limit
  else
    rows = rows.slice offset
  return rows


module.exports =

  makePredicate: makePredicate

  queryData: (data, query) ->

    query = common.preprocess query
    filterFn = makePredicate query.query
    filteredData = data.filter filterFn
    rows = applyOptions filteredData, query.options
    return rows
