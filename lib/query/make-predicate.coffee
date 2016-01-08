_ = require 'lodash'
common = require '../common'

TYPES = common.TYPES

evaluateQuery = (row, query) ->
  match = switch query.type
    when TYPES.AND
      evaluateAndQuery row, query
    when TYPES.OR
      evaluateOrQuery row, query
    else # Q or RAW
      evaluateBasicQuery row, query
  match = not match if query.negate
  return match

evaluateAndQuery = (row, query) ->
  queries = query.queries or []
  match = queries.every (q) ->
    evaluateQuery row, q
  return match

evaluateOrQuery = (row, query) ->
  queries = query.queries or []
  match = queries.some (q) ->
    evaluateQuery row, q
  return match

evaluateBasicQuery = (row, query) ->
  if query.field? and query.match?
    return row[query.field] == query.match
  else
    # For now, handle only basic matching
    return true

module.exports = (query) ->
  return (row) ->
    return evaluateQuery row, query
