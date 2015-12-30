BaseFacet = require './base-facet'

class PostgresFacet extends BaseFacet

  ASC: 'ASC'
  DESC: 'DESC'

  applyFacetField: (queryComponents, facetOpts) ->
    selectFields = facetOpts.field + ', ' + facetOpts.countField
    queryComponents.SELECT = selectFields

  applyFacetSort: (queryComponents, facetOpts) =>
    if facetOpts.sortBy is @VALUE
      orderBy = facetOpts.field
    else
      orderBy = facetOpts.countField
    dir = if facetOpts.dir is 1 then @ASC else @DESC
    orderBy += ' ' + dir
    queryComponents['ORDER BY'] = orderBy

  applyFacetImpl: (queryComponents, facetOpts) =>
    facetOpts.countField = "COUNT(#{facetOpts.field})"
    @applyFacetField queryComponents, facetOpts
    @applyFacetSort queryComponents, facetOpts
    return queryComponents


module.exports = (new PostgresFacet).applyFacet
