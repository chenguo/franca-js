_ = require 'lodash'
common = require '../common'
facet = require './facet'
query = require './query'
options = require './options'

processRaw = (components, rawStr) ->
  # If there are any components, treat raw query
  # as a WHERE
  if _.isEmpty components
    components.RAW = rawStr
  else
    components = processWhere components, rawStr
  return components

processWhere = (components, whereStr) ->
  if not components.FROM?
    throw new Error 'No table specified'
  if whereStr? and whereStr isnt ''
     components.WHERE = whereStr
  return components

processQuery = (components, q) ->
  qStr = query.toPg q.query
  if q.query.type is common.TYPES.RAW
    components = processRaw components, qStr
  else
    components = processWhere components, qStr
  return components

module.exports = (q) ->
  q = common.preprocess q
  components = {}
  components = _.merge components, options.toPg q.options
  if q.facet?
    components = facet.toPg components, q.facet
  # Core query treatment depends on options / facets
  components = processQuery components, q
  return components
