_ = require 'lodash'
common = require '../common'
pgComponents = require('../components').toPg

CLAUSE_MAPPING =
  query:
    fields:
      ['select', 'table', 'where', 'groupBy',
      'orderBy', 'limit', 'offset']
    clauseMap:
      select: 'SELECT'
      table: 'FROM'
      where: 'WHERE'
      groupBy: 'GROUP BY'
      orderBy: 'ORDER BY'
      limit: 'LIMIT'
      offset: 'OFFSET'
  insert:
    fields: ['table', 'insert', 'conflict', 'update']
    clauseMap:
      table: 'INSERT INTO'
      conflict: 'ON CONFLICT'
      update: 'DO UPDATE SET'
  update:
    fields: ['table', 'update', 'where']
    clauseMap:
      table: 'UPDATE'
      update: 'SET'
      where: 'WHERE'
  remove:
    fields: ['table', 'where']
    clauseMap:
      table: 'DELETE FROM'
      where: 'WHERE'

clauseValCombiner = (components, fields, clauseMap) ->
  valsWithClauses = fields.map (c) ->
    val = components[c]
    if val? and val isnt ''
      clause = clauseMap[c] or ''
      clause += ' ' if clause isnt ''
      val = clause + val
    val
  valsWithClauses
    .filter((v) -> not _.isEmpty v)
    .join ' '

getClauseMap = (q) ->
  if common.isInsert(q, 'regular') or common.isUpsert(q, 'regular')
    clauseField = 'insert'
  else if common.isUpdate q, 'regular'
    clauseField = 'update'
  else if common.isRemove q, 'regular'
    clauseField = 'remove'
  else
    clauseField = 'query'
  CLAUSE_MAPPING[clauseField]

combineComponents = (transComps, q) ->
  return transComps.raw if transComps.raw?
  transComps.select ?= '*'
  clauses = getClauseMap q
  clauseValCombiner transComps, clauses.fields, clauses.clauseMap

getPickFirstRowQuery = (q, primField) ->
  q.options ?= {}
  opt = q.options
  opt.fields = [primField]
  opt.sort = [[primField, 1]]
  opt.limit = 1
  "#{primField} = (#{pgTranslate q})"

processSubQuery = (transComps, q) ->
  if transComps.singleRowField?
    subQ = _.cloneDeep q
    delete subQ.options.singleRow
    if common.isWrite subQ
      delete subQ.type
      delete subQ.action_type
      delete subQ.write
    transComps.where = getPickFirstRowQuery subQ, transComps.singleRowField
  transComps

pgTranslate = (q) ->
  translatedComponents = pgComponents q
  translatedComponents = processSubQuery translatedComponents, q
  translated = combineComponents translatedComponents, q
  return translated


module.exports = pgTranslate
