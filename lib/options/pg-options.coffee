_ = require 'lodash'
common = require './common'


rowOptions = (opts) ->
  rowOpts = []
  unless isNaN opts.offset
    rowOpts.push 'OFFSET ' + parseInt opts.offset
  unless isNaN opts.limit
    rowOpts.push 'LIMIT ' + parseInt opts.limit
  return rowOpts.join ' '

sortValue = common.makeSortValueFormatter 'ASC', 'DESC'

sortOptions = (opts) ->
  orderings = common.getSorts opts, sortValue
  sortStr = ''
  if orderings? and orderings.length > 0
    sorts = orderings.map (order) -> order[0] + ' ' + sortValue order[1]
    sortStr = 'ORDER BY ' + sorts.join ', '
  return sortStr

toPg = (opts) ->
  rowOpts = rowOptions opts
  sortOpts = sortOptions opts
  combined = ''
  if sortOpts then combined += sortOpts
  if rowOpts
    if combined then combined += ' '
    combined += rowOpts
  return combined

module.exports =
  toPg: toPg
