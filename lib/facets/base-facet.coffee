_ = require 'lodash'
r = require('app-root-path').require
common = r 'lib/common'

class BaseFacet

  COUNT: 'count'
  VALUE: 'value'
  DEFAULT_SORT:
    count: -1
    value: 1

  parseSortDir: common.makeSortValueFormatter 1, -1

  parseSortBy: (sortBy) =>
    sortBy = sortBy.toLowerCase()
    if sortBy is @COUNT or sortBy is @VALUE
      return sortBy
    else
      throw new Error 'Facet sort field must be "count" or "value": ' + sortBy

  formatSortOpts: (sortOpts) ->
    switch
      when typeof sortOpts is 'number'
        sortDir = @parseSortDir sortOpts
      when typeof sortOpts is 'string'
        sortBy = @parseSortBy sortOpts
      when sortOpts instanceof Object
        if @COUNT of sortOpts
          sortBy = @COUNT
          sortDir = @parseSortDir sortOpts[@COUNT]
        else if @VALUE of sortOpts
          sortBy = @VALUE
          sortDir = @parseSortDir sortOpts[@VALUE]
        else
          s = JSON.stringify sortOpts
          throw new Error 'Invalid focet sort specification: ' + s
    sortBy ?= @COUNT
    sortDir ?= @DEFAULT_SORT[sortBy]
    return dir: sortDir, sortBy: sortBy

  formatOpts: (opts) =>
    unless opts.field?
      throw new Error 'No field provided for facet options: ' + JSON.stringify opts
    sortOpts = @formatSortOpts opts.sort
    facetSort = _.merge field: opts.field, sortOpts
    return facetSort

  applyFacets: (facetOpts, queryComponents) ->
    facetOpts = @formatOpts facetOpts
    @applyFacetsImpl facetOpts, queryComponents


module.exports = BaseFacet
