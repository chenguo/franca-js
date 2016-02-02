common = require '../../common'

COUNT = 'count'
VALUE = 'value'
DEFAULT_SORT =
  count: -1
  value: 1

parseSortDir = common.makeSortValueFormatter 1, -1

parseSortBy = (sortBy) =>
    sortBy = sortBy.toLowerCase()
    if sortBy is COUNT or sortBy is VALUE
      return sortBy
    else
      throw new Error 'Facet sort field must be "count" or "value": ' + sortBy

module.exports =

  COUNT: 'count'
  VALUE: 'value'

  parseSortDir: parseSortDir

  formatSortOpts: (sortOpts) ->
    switch
      when typeof sortOpts is 'number'
        sortDir = parseSortDir sortOpts
      when typeof sortOpts is 'string'
        if common.isAscVal sortOpts
          sortDir = 1
        else if common.isDescVal sortOpts
          sortDir = -1
        else
          sortBy = parseSortBy sortOpts
      when sortOpts instanceof Object
        if COUNT of sortOpts
          sortBy = COUNT
          sortDir = parseSortDir sortOpts[COUNT]
        else if @VALUE of sortOpts
          sortBy = VALUE
          sortDir = parseSortDir sortOpts[VALUE]
        else
          s = JSON.stringify sortOpts
          throw new Error 'Invalid focet sort specification: ' + s
    sortBy ?= COUNT
    sortDir ?= DEFAULT_SORT[sortBy]
    return dir: sortDir, sortBy: sortBy
