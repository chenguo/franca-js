_ = require 'lodash'
common = require '../../common'
facetCommon = require './common'

class BaseFacet

  COUNT: facetCommon.COUNT
  VALUE: facetCommon.VALUE

  formatOpts: (opts) =>
    unless opts.field?
      throw new Error 'No field provided for facet options: ' + JSON.stringify opts
    sortOpts = facetCommon.formatSortOpts opts.sort
    facetSort = _.merge field: opts.field, sortOpts
    return facetSort

  applyFacet: (queryComponents, facetOpts) =>
    facetOpts = @formatOpts facetOpts
    @applyFacetImpl queryComponents, facetOpts


module.exports = BaseFacet
