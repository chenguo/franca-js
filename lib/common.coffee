module.exports =
  preprocess: (q) ->
    opts = q.options
    query = switch
      when q.query? then q.query
      when q.filter? then q.filter
      else q
    return {
      query: query
      options: opts
    }
