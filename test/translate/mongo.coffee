common = require '../common'
franca = require '../../index'
testCases = require './test-cases'

translations =
  sampleQuery:
    collection: testCases.testTable
    query:
      price: $lte: 100
    options:
      skip: 50
      limit: 10

  sampleFacet:
    collection: testCases.testTable
    pipeline: [
      $match:
        population: $gte: 1000000
    ,
      $group:
        _id: '$city'
        count: $sum: 1
    ,
      $sort: _id: 1
    ]

testFn = common.makeTester testCases, franca.toMongo, translations

describe 'Mongo integration tests', () ->

  it 'translate a Mongo query', () ->
    testFn 'sampleQuery'

  it 'translate multiple Mongo queries', () ->
    testFn 'sampleQuery'
    testFn 'sampleQuery'

  it 'translate a Mongo facet', () ->
    testFn 'sampleFacet'
