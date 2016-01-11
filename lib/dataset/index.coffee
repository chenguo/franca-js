common = require '../common'
makePredicate = require './make-predicate'
facets = require './facets'

# Evaluator for Franca queries on in memory data

applyOptions = (rows, options) ->
  offset = options.offset or 0
  if options.limit
    rows = rows.slice offset, offset + options.limit
  else
    rows = rows.slice offset
  return rows

filterData = (rows, query) ->
  filterFn = makePredicate query.query
  return rows.filter filterFn

module.exports =

  makePredicate: makePredicate

  query: (data, query) ->
    query = common.preprocess query
    filteredData = filterData data, query
    rows = applyOptions filteredData, query.options
    return rows

  facets: (data, query) ->
    query = common.preprocess query
    filteredData = filterData data, query
    console.log filteredData
    dataFacets = facets.generateFacets filteredData, query.facet
    return dataFacets
