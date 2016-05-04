common = require '../../common'
BaseQuery = require './base'

class SolrQuery extends BaseQuery

  toNative: (query) =>
    query = common.objectify query
    solrQuery = @buildQuery query
    return solrQuery

  negateQuery: (qstr) ->
    qstr = '(*:* NOT ' + qstr + ')'
    return qstr

  buildEmptyImpl: () -> return '*:*'

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
    if @matchNull q
      qstr = @negateQuery qstr
    return qstr

  buildRangeMatchImpl: (q) =>
    lte = q.range.lte or q.range.lt or '*'
    gte = q.range.gte or q.range.gt or '*'
    rangeStr = "[#{gte} TO #{lte}]"
    if q.range.lt? or q.range.gt?
      conds = [rangeStr]
      if q.range.gt?
        conds.push 'NOT ' + q.range.gt
      if q.range.lt?
        conds.push 'NOT ' + q.range.lt
      rangeStr = '(' + conds.join(' ') + ')'
    qstr = q.field + ":" + rangeStr
    qstr = @negateQuery qstr if q.negate
    return qstr

  translateAnchors: (regStr) ->
    # Solr regexes are implicit full string matches.
    # Add .* to remove this implicitness
    # Use .* and lackthereof to simulate anchors that
    # may be present
    if /^\/\^/.test regStr
      noStartWildcard = true
      regStr = regStr.replace /^\/\^/, '/'
    if /\$\/$/.test regStr
      noEndWildcard = true
      regStr = regStr.replace /\$\/$/, '/'
    unless noStartWildcard or /^\/\.\*/.test regStr
      regStr = regStr.replace /^\//, "/.*"
    unless noEndWildcard or /\.\*\$/.test regStr
      regStr = regStr.replace /\/$/, ".*/"
    return regStr

  translateCharacterClasses: (regStr) ->
    # Some popular character classes are not supported
    # by Solr
    regStr = regStr.replace /\\d/, '[0-9]'
    regStr = regStr.replace /\\D/, '[^0-9]'
    regStr = regStr.replace /\\w/, '[A-Za-z0-9_]'
    regStr = regStr.replace /\\W/, '[^A-Za-z0-9_]'
    return regStr

  # Solr's regex format is different than the
  # style that Javascript uses. Do some *very*
  # basic translations
  translateRegex: (regStr) =>
    regStr = @translateAnchors regStr
    regStr = @translateCharacterClasses regStr
    return regStr

  buildRegexMatchImpl: (q) ->
    regStr = @getRegexStr q.regexp
    qstr = q.field + ':' + @translateRegex regStr
    qstr = @negateQuery qstr if q.negate
    return qstr

  buildCompoundImpl: (q) ->
    if q.type is @TYPES.AND then condOp = 'AND'
    else condOp = 'OR'
    conds = q.queries.map (query) => @buildQuery query
    qstr = '(' + conds.join(" #{condOp} ") + ')'
    qstr = @negateQuery qstr if q.negate
    return qstr

  buildRawImpl: (q) ->
    rawQuery = q.raw
    if 'string' is not typeof rawQuery
      throw new Error 'Raw Solr query is not a string: ' + rawQuery
    return rawQuery


module.exports = (new SolrQuery).convertQuery
