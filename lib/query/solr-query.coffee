common = require './common'
DBQuery = require './db-query'

TYPES = common.TYPES

class SolrQuery extends DBQuery

  toNative: (query) =>
    query = @objectify query
    solrQuery = @buildQuery query
    return solrQuery

  negateQuery: (qstr) ->
    qstr = '(*:* NOT ' + qstr + ')'
    return qstr

  buildMatchImpl: (q) =>
    qstr = q.field + ':"' + q.match + '"'
    qstr = @negateQuery qstr if q.negate
    return qstr

  buildMatchInImpl: (q) =>
    vals = q.match.map (v) -> '"' + v + '"'
    qstr = q.field + ':(' + vals.join(' OR ') + ')'
    qstr = @negateQuery qstr if q.negate
    return qstr

  buildNullMatch: (q) =>
    qstr = q.field + ':[* TO *]'
    unless q.negate
      qstr = @negateQuery qstr
    return qstr

  buildRangeMatchImpl: (q) =>
    min = q.range.min or '*'
    max = q.range.max or '*'
    qstr = "#{q.field}:[#{min} TO #{max}]"
    qstr = @negateQuery qstr if q.negate
    return qstr

  translateAnchors: (regStr) ->
    # Solr regexes are implicit full string matches.
    # Add .* to remove this implicitness 
    # Use .* and lackthereof to simulate anchors that
    # may be present


  # Solr's regex format is different than the
  # style that Javascript uses. Do some *very*
  # basic translations
  translateRegex: (regStr) =>
    regStr = @translateAnchors regStr

  buildRegexMatchImpl: (q) ->
    reg = q.regexp
    if q.regexp instanceof RegExp
      reg = q.regexp.toString()
    else
      reg = '/' + reg + '/'
    return @translateRegex reg

  buildEmptyImpl: (q) ->
    return '*:*'

solrQuery = new SolrQuery

module.exports =
  toNative: solrQuery.toNative