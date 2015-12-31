BaseFacet = require './base'

class SolrFacet extends BaseFacet

  applyFacetField: (queryComponents, facetOpts) ->
    queryComponents['facet.field'] = facetOpts.field

  indexSortError: () ->
    throw new Error 'Solr does not support descending sort on facet values'

  countSortError: () ->
    throw new Error 'Solr does not support ascending sort on facet counts'

  applyFacetSort: (queryComponents, facetOpts) =>
    if facetOpts.sortBy is @VALUE
      sortBy = 'index'
      @indexSortError() if facetOpts.dir is -1
    else
      sortBy = 'count'
      @countSortError() if facetOpts.dir is 1
    queryComponents['facet.sort'] = sortBy

  applyFacetImpl: (queryComponents, facetOpts) =>
    @applyFacetField queryComponents, facetOpts
    @applyFacetSort queryComponents, facetOpts
    return queryComponents

module.exports = (new SolrFacet).applyFacet
