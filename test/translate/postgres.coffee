require 'should'
common = require '../common'
franca = require '../../index'
testCases = require './test-cases'

translations =
  sampleQuery: "SELECT * FROM #{testCases.testTable} WHERE price <= 100 LIMIT 10 OFFSET 50"
  compoundQuery: "SELECT brand, size FROM #{testCases.testTable} WHERE (type = 'pants' AND price <= 100)"
  sampleFacet: "SELECT city, COUNT(city) FROM #{testCases.testTable} WHERE population >= 1000000 GROUP BY city ORDER BY city ASC"

testFn = common.makeTester testCases, franca.toPg, translations

describe 'Postgres integration tests', () ->

  it 'translate a Postgres query', () ->
    testFn 'sampleQuery'

  it 'translate multiple Postgres queries', () ->
    testFn 'sampleQuery'
    testFn 'sampleQuery'

  it 'translate a compound Postgres query', () ->
    testFn 'compoundQuery'

  it 'translate a Postgres facet', () ->
    testFn 'sampleFacet'

  it 'throw error when no table given', () ->
    franca.toPg.bind(null, testCases.noTable).should.throw()

  it 'translate a raw Postgres query', () ->
    raw = 'select * from table'
    rawQuery =
      type: franca.TYPES.RAW
      raw: raw
    translated = franca.toPg rawQuery
    translated.should.be.eql raw

  it 'translate a raw Postgres query with options', () ->
    rawWhere = "price <= 100 AND type = 'pants'"
    rawQuery =
      type: franca.TYPES.RAW
      raw: rawWhere
      options:
        table: testCases.testTable
    translated = franca.toPg rawQuery
    translated.should.be.eql "SELECT * FROM #{testCases.testTable} WHERE #{rawWhere}"
