_ = require 'lodash'
r = require('app-root-path').require
common = r 'lib/common'

facet = require './facet'
query = require './query'
options = require './options'

module.exports = (q) ->
  q = common.preprocess q
  components = q: query.toSolr q.query
  components = _.merge components, options.toSolr q.options
  return components