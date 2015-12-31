_ = require 'lodash'

getSorts = (opts, formatter) ->
  if opts.sort?
    if opts.sort instanceof Array
      orderings = opts.sort.map (s) ->
        [s[0], formatter s[1]]
    else if opts.sort instanceof Object
      orderings = _.map opts.sort, (v, k) ->
        [k, formatter v]
    else
      unless typeof opts.sort is 'string'
        msg = JSON.stringify opts.sort
      else
        msg = opts.sort
      throw new Error 'Invalid sort option format: ' + msg
    return orderings

module.exports =
  getSorts: getSorts

  makeSortValueFormatter: (ascVal, descVal) ->
    return (v) ->
      if typeof v is 'string'
        v = v.toLowerCase()
      v = switch v
        when 1, '1', 'asc', 'ascending' then ascVal
        when -1, '-1', 'desc', 'descending' then descVal
        else
          throw new Error 'Invalid field sort direction: ' + v
      return v
