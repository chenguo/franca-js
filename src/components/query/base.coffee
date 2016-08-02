common = require '../../common'

class BaseQuery

  TYPES: common.TYPES

  convertQuery: (query) =>
    query = common.objectify query
    converted = @buildQuery query
    return converted

  buildQuery: (q) ->
    switch q.type
      when @TYPES.RAW
        query = @buildRaw q
      when @TYPES.AND, @TYPES.OR
        query = @buildCompound q
      else
        query = @buildSingle q
    return query

  buildSingle: (q) ->
    if q.field?
      if q.match?
        query = @buildMatch q
      else if q.null?
        query = @buildNullMatch q
      else if q.range?
        query = @buildRangeMatch q
      else if q.regexp?
        query = @buildRegexMatch q
    else if q.text?
      query = @buildFullTextSearch q
    else
      query = @buildEmpty q
    return if query? then query else {}

  notImplemented: ->
    throw new Error 'not implemented'

  # Raw query passthrough
  buildRaw: (q) ->
    unless q.raw?
      throw new Error "No query given for raw query passthrough: " + q
    @buildRawImpl q

  # Standard single value equality check
  # query
  buildMatch: (q) ->
    if q.match instanceof Array and
       q.match.length is 1
      q.match = q.match[0]
    if q.match instanceof Array
      @buildMatchInImpl q
    else
      @buildMatchImpl q

  # Match a null / empty value
  buildNullMatch: (q) -> @buildNullMatchImpl q

  matchNull: (q) ->
    # XOR. Use not to ensure boolean
    return not q.null isnt not q.negate

  # Query within a range
  buildRangeMatch: (q) ->
    if (q.range not instanceof Object) or not
       (q.range.lt? or q.range.lte? or
        q.range.gt? or q.range.gte?)
      throw new Error "Range query must contain min or max: " + q
    @buildRangeMatchImpl q

  # Query with a regular express
  buildRegexMatch: (q) ->
    unless q.regexp instanceof RegExp or typeof q.regexp is 'string'
      throw new Error 'Invalid regular expression query: ' + q.regexp
    @buildRegexMatchImpl q

  getRegexStr: (reg) ->
    if reg instanceof RegExp
      reg = reg.toString()
    else
      reg = '/' + reg if reg[0] isnt '/'
      reg = reg + '/' if reg[reg.length - 1] isnt '/'
    return reg

  # Full text search query
  buildFullTextSearch: @::notImplemented

  # Compound query
  buildCompound: (q) ->
    unless q.queries instanceof Array
      throw new Error 'Compound query not specified as an array'
    if q.negate
      # Apply De Morgan's
      q.type = if q.type is @TYPES.AND then @TYPES.OR else @TYPES.AND
      q.queries = q.queries.map (subq) ->
        subq.negate = not subq.negate
        return subq
      q.negate = false
    @buildCompoundImpl q

  buildEmpty: (q) ->
    if q.negate
      throw new Error 'Cannot negate empty query'
    @buildEmptyImpl q


module.exports = BaseQuery
