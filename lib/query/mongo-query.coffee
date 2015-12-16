_ = require 'lodash'
common = require './common'
DBQuery = require './db-query'

TYPES = common.TYPES

class MongoQuery extends DBQuery

  toNative: (query) =>
    query = @objectify query
    mongoQuery = @buildQuery query
    return mongoQuery

  buildMatchImpl: (q) ->
    fieldQ = if q.negate then $ne: q.match else q.match
    return _.set {}, q.field, fieldQ

  buildMatchInImpl: (q) ->
    op = if q.negate then '$nin' else '$in'
    return _.set {}, [q.field, op], q.match

  buildNullMatchImpl: (q) ->
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

  buildRangeMatchImpl: (q) ->
    min = q.range.min
    max = q.range.max
    field = q.field
    queries = []
    if min?
      if q.negate then rq = $lt: min
      else rq = $gte: min
      queries.push _.set {}, field, rq
    if max?
      if q.negate then rq = $gt: max
      else rq = $lte: max
      queries.push _.set {}, field, rq
    if queries.length > 1
      if q.negate
        return $or: queries
      else
        return $and: queries
    else
      return queries[0]

  buildRegexMatchImpl: (q) ->
    try
      regex = new RegExp q.regexp, q.regFlags
    catch e
      throw new Error 'Query regex fail: ' + e
    regq = if q.negate then $not: regex else regex
    return _.set {}, q.field, regq

  buildRawImpl: (q) ->
    rawQuery = q.raw
    if 'string' is typeof rawQuery
      try
        raw = JSON.parse rawQuery
      catch e
        throw new Error 'Failed parsing raw query string: ' + e
    else if rawQuery instanceof Object
      raw = rawQuery
    unless raw?
      throw new Error "Query is not a JSON string or Object"
    return raw

  buildCompoundImpl: (q) =>
    if q.type is TYPES.AND then condOp = '$and'
    else condOp = '$or'
    return _.set {}, condOp, q.queries.map (query) => @buildQuery query

mongoQuery = new MongoQuery

module.exports =
  toNative: mongoQuery.toNative
