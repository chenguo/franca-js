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

  applyFacetLimit: (pipeline, queryComponents) ->
    if queryComponents.options? and queryComponents.options.limit?
      pipeline.push $limit: queryComponents.options.limit

  applyFacetImpl: (queryComponents, facetOpts) =>
    pipeline = []
    @applyFacetQuery pipeline, queryComponents
    @applyFacetField pipeline, facetOpts
    @applyFacetSort pipeline, facetOpts
    @applyFacetLimit pipeline, queryComponents
    return pipeline


module.exports = (new MongoFacet).applyFacet
