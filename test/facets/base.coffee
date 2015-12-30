require 'should'
r = require('app-root-path').require
BaseFacet = r 'lib/facets/base-facet'
common = r 'test/common'
testCases = require './test-cases'

canonicalOpts =
  basic:
    field: 'category'
    dir: -1
    sortBy: BaseFacet::COUNT

  countAsc:
    field: 'category'
    dir: 1
    sortBy: BaseFacet::COUNT

  byValue:
    field: 'category'
    dir: 1
    sortBy: BaseFacet::VALUE

  valueDesc:
    field: 'category'
    dir: -1
    sortBy: BaseFacet::VALUE


baseFacet = new BaseFacet

testFacet = (key) ->
  testCase = testCases[key].facet
  expected = canonicalOpts[key]
  common.testTranslation baseFacet.formatOpts, expected, testCase


describe 'Base facet option canonicalization tests', () ->

  it 'should default to sort descending by count', () ->
    testFacet 'basic'

  it 'should canonicalize sort ascending', () ->
    testFacet 'countAsc'

  it 'should canonicalize sort by value', () ->
    testFacet 'byValue'

  it 'should canonicalize sort descending by value', () ->
    testFacet 'valueDesc'
