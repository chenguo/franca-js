_ = require 'lodash'
common = require './common'
facet = require './facet'
query = require './query'
options = require './options'

CLAUSES = ['SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY',
           'LIMIT', 'OFFSET']

convertQuery = (q) ->
  converted = options.toPg q.options
  converted.WHERE = query.toPg q.query
  converted.SELECT = '*' unless converted.SELECT?
  return converted

applyFacetOpts = (components, facetOpts) ->
  return facet.toPg components, facetOpts

combineComponents = (components) ->
  pgQuery = CLAUSES.reduce (str, c) ->
    val = components[c]
    if val? and val isnt ''
      str += ' ' if str isnt ''
      str += "#{c} #{val}"
    return str
  , ''
  return pgQuery

module.exports =
  toPg: (q) ->
    q = common.preprocess q
    components = convertQuery q
    if q.facet?
      components = applyFacetOpts components, q.facet
    pgQuery = combineComponents components
    return pgQuery
