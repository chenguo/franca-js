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
    else q

module.exports =
  preprocess: (q) ->
    processed =
      query: canonicalizeQuery q
      options: canonicalizeOpts q
    return processed
