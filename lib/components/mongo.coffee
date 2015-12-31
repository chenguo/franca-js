common = require '../common'
facet = require './facet'
query = require './query'
options = require './options'

module.exports = (q) ->
  q = common.preprocess q
  components =
    query: query.toMongo q.query
    options: options.toMongo q.options
  if q.facet?
    components = facet.toMongo components, q.facet
  return components
