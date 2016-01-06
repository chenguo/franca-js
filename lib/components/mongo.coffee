common = require '../common'
facet = require './facet'
query = require './query'
options = require './options'

module.exports = (q) ->
  q = common.preprocess q
  opts = options.toMongo q.options
  if opts.collection?
    collection = opts.collection
    delete opts.collection
  components =
    query: query.toMongo q.query
    options: opts
  if q.facet?
    components =
      pipeline: facet.toMongo components, q.facet
  components.collection = collection if collection?
  return components
