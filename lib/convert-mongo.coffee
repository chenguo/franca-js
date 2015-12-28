common = require './common'
query = require './query'
options = require './options'

module.exports =
  toMongo: (q) ->
    q = common.preprocess q
    converted =
      query: query.toMongo q.query
      options: options.toMongo q.options
    return converted
