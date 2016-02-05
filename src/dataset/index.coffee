_ = require 'lodash'
common = require '../common'
optsCommon = require '../components/options/common'
makePredicate = require './make-predicate'
facets = require './facets'

# Evaluator for Franca queries on in memory data

singleCmp = (ordering, a, b) ->
  field = ordering[0]
  sortDir = ordering[1]
  f1 = _.get a, field
  f2 = _.get b, field
  if f1 < f2 then dir = -1
  else if f2 < f1 then dir = 1
  else dir = 0
  return dir * sortDir

makeCmpFn = (orderings) ->
  return (a, b) ->
    order = 0
    orderings.some (o) ->
      dir = singleCmp o, a, b
      if dir != 0
        order = dir
        return true
    return order

applySortOptions = (rows, options) ->
  formatter = optsCommon.makeSortValueFormatter 1, -1
  orderings = optsCommon.getSorts options, formatter
  if orderings?
    rows.sort makeCmpFn orderings
  return rows

applyLimitOffsetOptions = (rows, options = {}) ->
  offset = options.offset or 0
  if options.limit
    rows = rows.slice offset, offset + options.limit
  else
    rows = rows.slice offset
  return rows

applyOptions = (rows, options) ->
  rows = applySortOptions rows, options
  rows = applyLimitOffsetOptions rows, options
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
    dataFacets = facets.generateFacets filteredData, query.facet
    dataFacets = applyLimitOffsetOptions dataFacets, query.options
    return dataFacets
