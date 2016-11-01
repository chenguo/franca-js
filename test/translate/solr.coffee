common = require '../common'
franca = require '../../index'
testCases = require './test-cases'

translations =
  sampleQuery: 'q=price:[* TO 100]&start=50&rows=10'
  sampleFacet: "q=population:[1000000 TO *]&facet.field=city&facet.sort=index&facet=true"

testFn = common.makeTester testCases, franca.toSolr, translations

describe 'Solr integration tests', () ->

  it 'translate a Solr query', () ->
    testFn 'sampleQuery'

  it 'translate multiple Solr queries', () ->
    testFn 'sampleQuery'
    testFn 'sampleQuery'

  it 'translate a Solr facet', () ->
    testFn 'sampleFacet'
