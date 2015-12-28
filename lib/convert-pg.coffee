common = require './common'
query = require './query'
options = require './options'

module.exports =
  toPg: (q) ->
    q = common.preprocess q
    convertedQuery = query.toPg q.query
    convertedOptions = options.toPg q.options
    pgStr = ''
    if convertedQuery
      pgStr = 'WHERE ' + convertedQuery
    if convertedOptions
      if pgStr then pgStr += ' '
      pgStr += convertedOptions
    return pgStr
