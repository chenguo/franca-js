_ = require 'lodash'
common = require '../common'
facet = require './facet'
query = require './query'
options = require './options'


module.exports = (q) ->
  q = common.preprocess q
  components = {}
  whereStr = query.toPg q.query
  if whereStr? and whereStr isnt ''
    components.WHERE = whereStr
  components = _.merge components, options.toPg q.options
  if q.facet?
    components = facet.toPg components, q.facet
  return components
