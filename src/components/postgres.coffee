_ = require 'lodash'
common = require '../common'
pgFacet = require('./facet').toPg
pgQuery = require('./query').toPg
pgWrite = require('./write').toPg
pgOptions = require('./options').toPg

preProcess = (q) ->
  if common.isUpsert q, 'regular'
    q.write =
      query: q.query
      update: q.write
    delete q.query
  common.preprocess q

processOptAndFacet = (q, components = {}) ->
  components = _.merge components, pgOptions(q.options, q)
  components = pgFacet components, q.facet if q.facet?
  return components

processQueryAndWrite = (q, components = {}) ->
  components = processQuery components, q
  if common.isWrite q
    writeComp = pgWrite q
    if common.isUpsert q, 'regular'
      components = _.merge components, writeComp
    else
      components[getWriteCompField q] = writeComp
  return components

processQuery = (components, q) ->
  qStr = pgQuery q.query
  procFn = if common.isRaw q then processRaw else processWhere
  procFn components, qStr

processRaw = (components, rawStr) ->
  # If there are any components, treat raw query as a WHERE
  if _.isEmpty components
    components.raw = rawStr
  else
    components = processWhere components, rawStr
  return components

processWhere = (components, whereStr) ->
  if not components.table?
    throw new Error 'No table specified'
  if whereStr? and whereStr isnt ''
     components.where = whereStr
  return components

getWriteCompField = (q) ->
  if common.isRaw q
    'raw'
  else if common.isInsert(q, 'regular') or common.isUpsert(q, 'regular')
    'insert'
  else if common.isUpdate(q, 'regular')
    'update'
  else if common.isRemove q, 'regular'
    'remove'
  else
    throw new Error "Invalid Write Type: #{q.type}"


module.exports = (q) ->
  q = preProcess q
  components = processOptAndFacet q
  components = processQueryAndWrite q, components
  return components
