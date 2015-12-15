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
        query = @buildRawQuery q
      when TYPES.AND, TYPES.OR
        query = @buildCompoundQuery q
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

  # Standard single value equality check
  # query
  buildMatch: @::notImplemented

  # Match a null / empty value
  buildNulLMatch: @::notImplemented

  # Query within a range
  buildRangeMatch: @::notImplemented

  # Query with a regular express
  buildRegexMatch: @::notImplemented

  # Full text search query
  buildFullTextSearch: @::notImplemented

  # Raw query passthrough
  buildRawQuery: @::notImplemented

  # Compound query
  buildCompoundQuery: @::notImplemented

module.exports = DBQuery