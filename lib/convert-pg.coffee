common = require './common'
query = require './query'
options = require './options'

CLAUSES = ['SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY',
           'LIMIT', 'OFFSET']

module.exports =
  toPg: (q) ->
    q = common.preprocess q
    converted = options.toPg q.options
    converted.WHERE = query.toPg q.query
    converted.SELECT = '*' unless converted.SELECT?

    pgQuery = CLAUSES.reduce (str, c) ->
      if c of converted
        str += ' ' if str isnt ''
        str += "#{c} #{converted[c]}"
      return str
    , ''
    return pgQuery
