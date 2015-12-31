_ = require 'lodash'
common = require '../common'
facet = require './facet'
query = require './query'
options = require './options'

componentMaker = (protocol) ->
  return (q) ->
    q = common.preprocess q
    qComp = query[protocol] q.query
    optsComp = options[protocol] q.options
    components = _.merge qComp, optsComp
    if q.facet?
      components = facet[protocol] components, q.facet
    return components

module.exports =
  toMongo: require './mongo'
  toPg: require './postgres'
  toSolr: require './solr'
