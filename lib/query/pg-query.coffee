_ = require 'lodash'
common = require './common'
DBQuery = require './db-query'

TYPES = common.TYPES

class PGQuery extends DBQuery

  AND = 'AND'
  OR = 'OR'

  BETWEEN = 'BETWEEN'
  EQ = '='
  IN = 'IN'
  IS = 'IS'
  NOT_BETWEEN = 'NOT BETWEEN'
  NOT_EQ = '!='
  NOT_IS = 'IS NOT'
  NOT = 'NOT'
  NOT_IN = 'NOT IN'
  NULL = 'NULL'

  toNative: (query) =>
    query = @objectify query
    pgQuery = @buildQuery query
    return pgQuery

  tokenStr: () ->
    return Array::join.call arguments, ' '

  cond: (field, op, val) ->
    return @tokenStr field, op, val

  formatVal: (val) ->
    if typeof val is 'string'
      return "'#{val}'"
    else
      return val

  buildEmptyImpl: () -> return ''

  buildMatchImpl: (q) ->
    if q.negate
      op = '!='
    else
      op = '='
    val = "'#{q.match}'"
    qstr = @cond q.field, op, val
    return qstr

  buildMatchInImpl: (q) ->
    op = if q.negate then NOT_IN else IN
    vals = q.match
      .map(@formatVal)
      .join ', '
    qstr = @cond q.field, op, "(#{vals})"
    return qstr

  buildNullMatchImpl: (q) ->
    op = if q.negate then NOT_IS else IS
    qstr = @cond q.field, op, NULL
    return qstr

  buildBetween: (q) ->
    op = if q.negate then NOT_BETWEEN else BETWEEN
    r = q.range
    val = @tokenStr @formatVal(r.gte), AND, @formatVal(r.lte)
    qstr = @cond q.field, op, val
    return qstr

  rangeConds: (r) ->
    conds = []
    if r.gt?
      conds.push ['>', r.gt]
    else if r.gte?
      conds.push ['>=', r.gte]
    if r.lt?
      conds.push ['<', r.lt]
    else if r.lte?
      conds.push ['<=', r.lte]
    return conds

  negateRangeConds: (condPair) ->
    op = condPair[0]
    val = condPair[1]
    newOp = switch op
      when '<' then '>='
      when '<=' then '>'
      when '>' then '<='
      when '>=' then '<'
      else
        throw new Error 'Invalid range operator: ' + op
    return [newOp, val]

  rangeCondNegater: (neg) ->
    if neg
      return @negateRangeConds
    else
      return (x) -> x

  rangeStrFormatter: (field, negate, conds) ->
    condStrs = conds.map (condPair) =>
      @tokenStr field, condPair[0], condPair[1]
    if condStrs.length > 1
      op = if negate then OR else AND
      qstr = condStrs.join " #{op} "
    else
      qstr = condStrs[0]
    return qstr

  buildRangeMatchImpl: (q) ->
    range = q.range
    if range.lte? and range.gte?
      qstr = @buildBetween q
    else
      conds = @rangeConds(range).map (@rangeCondNegater q.negate)
      qstr = @rangeStrFormatter q.field, q.negate, conds
    return qstr


pgQuery = new PGQuery

module.exports =
  toNative: pgQuery.toNative
