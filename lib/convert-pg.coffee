_ = require 'lodash'
common = require './common'
facet = require './facet'
query = require './query'
options = require './options'

convertQuery = (q) ->
  converted = options.toPg q.options
  converted.WHERE = query.toPg q.query
  converted.SELECT = '*' unless converted.SELECT?
  return converted

applyFacetOpts = (components, facetOpts) ->
  return facet.toPg components, facetOpts

queryComponents = (q) ->
  q = common.preprocess q
  components = convertQuery q
  if q.facet?
    components = applyFacetOpts components, q.facet
  return components

module.exports =
  pgComponents: queryComponents

  toPg: (q) ->
    components = queryComponents q
    pgQuery = combineComponents components
    return pgQuery
