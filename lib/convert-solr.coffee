_ = require 'lodash'
Qs = require 'qs'

common = require './common'
query = require './query'
options = require './options'

module.exports =
  toSolr: (q, encode=false) ->
    q = common.preprocess q
    convertedQuery = q: query.toSolr q.query
    convertedOptions = options.toSolr q.options
    params = _.merge convertedQuery, convertedOptions
    qstr = Qs.stringify params, encode: encode
    return qstr
