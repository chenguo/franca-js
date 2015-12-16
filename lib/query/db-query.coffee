common = require './common'

TYPES = common.TYPES

class DBQuery

  # Ensure a query is a JSON object
  objectify: (input) ->
    if 'string' is typeof input
      try
        q = JSON.parse input
      catch e
        throw new Exception 'Failed to parse string query: ' + e
    else if input instanceof Object
      q = input
    else
      throw new Exception 'Malformed input query: ' + input
    return q

  buildQuery: (q) ->
    switch q.type
      when TYPES.RAW
        query = @buildRaw q
      when TYPES.AND, TYPES.OR
        query = @buildCompound q
      else
        # Default to QUERY.Q
        query = @buildSingle q
    return query

  buildSingle: (q) ->
    if q.queries
      q = q.queries[0]
    if q.field?
      if q.match?
        query = @buildMatch q
      else if q.null?
        query = @buildNullMatch q
      else if q.range?
        query = @buildRangeMatch q
      else if q.regexp?
        query = @buildRegexMatch q
    else
      query = @buildFullTextSearch q
    return query or {}

  notImplemented: ->
    throw new Error 'not implemented'

  # Raw query passthrough
  buildRaw: (q) ->
    unless q.raw?
      throw new Error "No query given for raw query passthrough: " + q
    @buildRawImpl q

  # Standard single value equality check
  # query
  buildMatch: (q) -> @buildMatchImpl q

  # Match a null / empty value
  buildNullMatch: (q) -> @buildNullMatchImpl q

  # Query within a range
  buildRangeMatch: (q) ->
    if (q.range not instanceof Object) or not
       (q.range.min? or q.range.max?)
      throw new Error "Range query must contain min or max: " + q
    @buildRangeMatchImpl q

  # Query with a regular express
  buildRegexMatch: (q) -> @buildRegexMatchImpl q

  # Full text search query
  buildFullTextSearch: @::notImplemented

  # Compound query
  buildCompound: (q) ->
    unless q.queries instanceof Array
      throw new Error 'Compound query not specified as an array'
    if q.negate
      # Apply De Morgan's
      q.type = if q.type is TYPES.AND then TYPES.OR else TYPES.AND
      q.queries = q.queries.map (subq) ->
        subq.negate = not subq.negate
        return subq
    @buildCompoundImpl q


module.exports = DBQuery