_ = require 'lodash'
common = require '../common'
facet = require './facet'
query = require './query'
options = require './options'

module.exports = (q) ->
  q = common.preprocess q
  components = q: query.toSolr q.query
  components = _.merge components, options.toSolr q.options
  if q.facet?
    components = facet.toSolr components, q.facet
  return components