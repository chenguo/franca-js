_ = require 'lodash'
Set = require 'es6-set'
facetCommon = require '../components/facet/common'

# N^2 implementation, because Javascript objects
# coerces numbers to strings for keys. Sigh.
getFacetValues = (data, field) ->
  facets = []
  data.forEach (row) ->
    val = _.get row, field
    found = facets.some (f) ->
      if f.value is val
        f.count += 1
        return true
    unless found
      facets.push value: val, count: 1
  return facets

arrayifyFacets = (facets) ->
  return Object.keys(facets).map (val) ->
    value: val
    count: facets[val]

sortFacetValues = (facets, sortOpts) ->
  if sortOpts.sortBy is facetCommon.VALUE
    valFn = (facet) -> facet.value
  else
    valFn = (facet) -> facet.count
  facets = facets.sort (a, b) ->
    valA = valFn a
    valB = valFn b
    cmpVal = switch
      when valA < valB then -1
      when valB < valA then 1
      else 0
    return cmpVal * sortOpts.dir
  return facets

module.exports =
  generateFacets: (data, facetOpts={}) ->
    facetValues = getFacetValues data, facetOpts.field
    sortOpts = facetCommon.formatSortOpts facetOpts.sort
    facets = sortFacetValues facetValues, sortOpts
    return facets
