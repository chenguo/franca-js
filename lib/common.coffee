canonicalizeOpts = (q) ->
  opts = q.options or {}
  # Ensure table is under options if it exists
  opts.table = q.table if q.table?
  if opts.columns?
    opts.fields = opts.columns
    delete opts.columns
  return opts

canonicalizeQuery = (q) ->
  query = switch
    when q.query? then q.query
    when q.filter? then q.filter
    when not q.facet? then q
    else {}

isAscVal = (v) ->
  return switch v
    when 1, '1', 'asc', 'ascending' then true
    else false

isDescVal = (v) ->
  return switch v
    when -1, '-1', 'desc', 'descending' then true
    else false

module.exports =
  TYPES:
    Q: 'Q'
    AND: 'AND'
    OR: 'OR'
    RAW: 'RAW'

  preprocess: (q) ->
    processed =
      query: canonicalizeQuery q
      options: canonicalizeOpts q
      facet: q.facet
    return processed

  isAscVal: isAscVal
  isDescVal: isDescVal

  makeSortValueFormatter: (ascVal, descVal) ->
    return (v) ->
      if typeof v is 'string'
        v = v.toLowerCase()
      v = switch
        when isAscVal v then ascVal
        when isDescVal v then descVal
        else
          throw new Error 'Invalid field sort direction: ' + v
      return v
