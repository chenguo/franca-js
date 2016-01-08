common = require '../common'
franca = require '../../index'
testCases = require './test-cases'

translations =
  sampleQuery: "SELECT * FROM #{testCases.testTable} WHERE price <= 100 LIMIT 10 OFFSET 50"
  sampleFacet: "SELECT city, COUNT(city) FROM #{testCases.testTable} WHERE population >= 1000000 GROUP BY city ORDER BY city ASC"

testFn = common.makeTester testCases, franca.toPg, translations

describe 'Postgres integration tests', () ->

  it 'translate a Postgres query', () ->
    testFn 'sampleQuery'

  it 'translate multiple Postgres queries', () ->
    testFn 'sampleQuery'
    testFn 'sampleQuery'

  it 'translate a Postgres facet', () ->
    testFn 'sampleFacet'
