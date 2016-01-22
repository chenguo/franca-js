_ = require 'lodash'
BaseQuery = require './base'

class PostgresQuery extends BaseQuery

  AND = 'AND'
  OR = 'OR'

  BETWEEN = 'BETWEEN'
  EQ = '='
  IN = 'IN'
  IS = 'IS'
  NOT_BETWEEN = 'NOT BETWEEN'
  NOT_EQ = '!='
  NOT_IN = 'NOT IN'
  NOT_IS = 'IS NOT'
  NOT_REG = '!~'
  NOT = 'NOT'
  NULL = 'NULL'
  REG = '~'

  tokenStr: () ->
    return Array::join.call arguments, ' '

  cond: (field, op, val) ->
    return @tokenStr field, op, val

  formatVal: (val) ->
    if typeof val is 'string'
      val = val.replace "'", "''"
      return "'#{val}'"
    else
      return val

  buildEmptyImpl: () -> return ''

  buildMatchImpl: (q) ->
    if q.negate
      op = '!='
    else
      op = '='
    val = @formatVal q.match
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

  # Strip '/' chars, wrap with single quotes
  formatRegStr: (regStr) ->
    regStr = regStr.replace /^\/|\/$/g, ''
    regStr = "'#{regStr}'"
    return regStr

  translateRegex: (regStr) ->
    # regStr = @translateAnchors regStr
    # regStr = @translateCharacterClasses regStr
    regStr = @formatRegStr regStr
    return regStr

  buildRegexMatchImpl: (q) ->
    regStr = @getRegexStr q.regexp
    op = if q.negate then NOT_REG else REG
    # Check existence first. undefined matches /i/ due to string coercion
    if q.regFlags? and /i/.test q.regFlags then op += '*'
    qstr = @tokenStr q.field, op, @translateRegex regStr
    return qstr

  buildCompoundImpl: (q) ->
    if q.type is @TYPES.AND then condOp = AND
    else condOp = OR
    conds = q.queries.map (query) => @buildQuery query
    qstr = '(' + conds.join(" #{condOp} ") + ')'
    return qstr

  buildRawImpl: (q) ->
    rawQuery = q.raw
    if 'string' is not typeof rawQuery
      throw new Error 'Raw Solr query is not a string: ' + rawQuery
    return rawQuery


module.exports = (new PostgresQuery).convertQuery

