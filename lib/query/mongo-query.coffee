common = require './common'
DBQuery = require './db-query'

TYPES = common.TYPES

class MongoQuery extends DBQuery

  toNative: (query) =>
    query = @objectify query
    mongoQuery = @buildQuery query
    return mongoQuery

  buildMatch: (q) ->
    fieldQ = if q.negate then $ne: q.match else q.match
    queryObj = {}
    queryObj[q.field] = fieldQ
    return queryObj

  buildNullMatch: (q) ->
    field = q.field
    cond = [ {}, {} ]
    if q.negate
      # Exists and not null
      cond[0][field] = $ne: null
      cond[1][field] = $exists: true
      return $and: cond
    else
      # Doesn't exist or null
      cond[0][field] = null
      cond[1][field] = $exists: false
      return $or: cond

  buildRangeMatch: (q) ->
    min = q.range.min
    max = q.range.max
    field = q.field
    queries = []
    if min?
      if q.negate then rq = $lt: min
      else rq = $gte: min
      query = {}
      query[field] = rq
      queries.push query
    if max?
      if q.negate then rq = $gt: max
      else rq = $lte: max
      query = {}
      query[field] = rq
      queries.push query
    if queries.length > 1
      # Or negated range queries, for below min or
      # above max
      if q.negate
        return $or: queries
      else
        return $and: queries
    else
      return queries[0]

  buildRegexMatch: (q) ->
    queryObj = {}
    try
      regex = new RegExp q.regexp, q.regFlags
    catch e
      throw new Error 'Query regex fail: ' + e
    queryObj[q.field] = if q.negate then $not: regex else regex
    return queryObj

  buildRawQuery: (q) ->
    try
      rawQuery = queryObject.queries[0].raw
      if 'string' is typeof rawQuery
        raw = JSON.parse rawQuery
      else
        raw = rawQuery
    catch e
      throw new Error 'Failed parsing raw query: ' + e

  buildCompoundQuery: (q) =>
    if q.type is TYPES.AND then condOp = '$and'
    else if q.type is TYPES.OR then condOp = '$or'
    else
      throw new Error 'Invalid compound query type: ' + q.type
    if q.queries instanceof Array
      queries = {}
      if q.negate
        # Apply De Morgan's
        condOp = if condOp is '$or' then '$and' else '$or'
        q.queries = q.queries.map (query) ->
          query.negate = not query.negate
          return query
      queries[condOp] = q.queries.map (query) => @buildQuery query
    else
      throw new Error 'Compound query not specified as an array'
    return queries


mongoQuery = new MongoQuery

module.exports =
  toNative: mongoQuery.toNative
