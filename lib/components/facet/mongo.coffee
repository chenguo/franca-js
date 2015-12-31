_ = require 'lodash'
BaseFacet = require './base'

class MongoFacet extends BaseFacet

  ASC: 1
  DESC: -1

  applyFacetQuery: (pipeline, queryComponents) ->
    unless _.isEmpty queryComponents.query
      pipeline.push $match: queryComponents.query

  applyFacetField: (pipeline, facetOpts) ->
    pipeline.push
      $group:
        _id: '$' + facetOpts.field
        count: $sum: 1

  applyFacetSort: (pipeline, facetOpts) ->
    $sort = {}
    orderBy = if facetOpts.sortBy is @VALUE then '_id' else 'count'
    $sort[orderBy] = facetOpts.dir
    pipeline.push $sort: $sort

  applyFacetImpl: (queryComponents, facetOpts) =>
    pipeline = []
    @applyFacetQuery pipeline, queryComponents
    @applyFacetField pipeline, facetOpts
    @applyFacetSort pipeline, facetOpts
    return pipeline


module.exports = (new MongoFacet).applyFacet
