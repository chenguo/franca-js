query = require './query'
#options = require './options'

toMongo = (q) ->
  opts = q.options
  q = q.query if q.query?
  converted =
    query: query.toMongo q
    #options: options.toMongo opts
  return converted


module.exports =
  toMongo: toMongo