_ = require 'lodash'
common = require '../common'

TYPES = common.TYPES

checkNegate = (match, query) ->
  match = not match if query.negate
  return match

evaluateQuery = (row, query) ->
  match = switch query.type
    when TYPES.AND
      evaluateAndQuery row, query
    when TYPES.OR
      evaluateOrQuery row, query
    else # Q or RAW
      evaluateBasicQuery row, query
  return match

evaluateAndQuery = (row, query) ->
  queries = query.queries or []
  match = queries.every (q) ->
    evaluateQuery row, q
  match = checkNegate match, query
  return match

evaluateOrQuery = (row, query) ->
  queries = query.queries or []
  match = queries.some (q) ->
    evaluateQuery row, q
  match = checkNegate match, query
  return match

evaluateBasicQuery = (row, query) ->
  if query.field?
    # Range query has special negation rules
    if query.range?
      return evaluateRangeQuery row, query
    else
      if query.match?
        match = evaluateMatchQuery row, query
      else if query.null?
        match =evaluateNullQuery row, query
      else if query.regexp?
        match = evaluateRegexpQuery row, query
      match = checkNegate match, query
      return match
  else if query.text?
    return evaluateFullTextQuery row, query
  return true

evaluateMatchQuery = (row, query) ->
  value = row[query.field]
  if query.match instanceof Array
    return query.match.some (match) -> value is match
  else
    return value is query.match

evaluateNullQuery = (row, query) ->
  return not row[query.field]?

evaluateRangeQuery = (row, query) ->
  range = query.range or {}
  value = row[query.field]
  return false unless value?
  failRangeCheck =
    (range.lt? and value >= range.lt) or
    (range.lte? and value > range.lte) or
    (range.gt? and value <= range.gt) or
    (range.gte? and value < range.gte)
  match = checkNegate not failRangeCheck, query
  return match

evaluateRegexpQuery = (row, query) ->
  pattern = new RegExp query.regexp, query.regFlags
  value = row[query.field]
  return pattern.test value

evaluteFullTextQuery = (row, query) ->
  throw new Error 'Fulltext query not yet supported'

module.exports = (query) ->
  return (row) ->
    query = query.query if query.query?
    return evaluateQuery row, query
