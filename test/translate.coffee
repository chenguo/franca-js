require 'should'
_ = require 'lodash'

franca = require '../index'
common = require './common'


testTable = 'tab'

sampleQuery =
  options:
    offset: 50
    limit: 10
    table: testTable
  query:
    type: franca.TYPES.Q
    field: 'price'
    range: lte: 100

translations =
  mongo:
    collection: testTable
    query:
      price: $lte: 100
    options:
      skip: 50
      limit: 10
  pg: "SELECT * FROM #{testTable} WHERE price <= 100 LIMIT 10 OFFSET 50"
  solr: 'q=price:[* TO 100]&start=50&rows=10'

sampleFacet =
  facet:
    field: 'city'
    sort: 'value'
  query:
    field: 'population'
    range: gte: 1000000
  table: testTable

facetTrans =
  mongo:
    collection: testTable
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
  pg: "SELECT city, COUNT(city) FROM #{testTable} WHERE population >= 1000000 GROUP BY city ORDER BY city ASC"
  solr: "q=population:[1000000 TO *]&facet.field=city&facet.sort=index"

describe 'General integration tests', () ->

  it 'translate a Mongo query', () ->
    common.testTranslation franca.toMongo, translations.mongo, sampleQuery

  it 'translate multiple Mongo queries', () ->
    common.testTranslation franca.toMongo, translations.mongo, sampleQuery
    common.testTranslation franca.toMongo, translations.mongo, sampleQuery

  it 'translate a Mongo facet', () ->
    common.testTranslation franca.toMongo, facetTrans.mongo, sampleFacet

  it 'translate a Postgres query', () ->
    pgQuery = _.cloneDeep sampleQuery
    pgQuery.table = testTable
    common.testTranslation franca.toPg, translations.pg, pgQuery

  it 'translate multiple Postgres queries', () ->
    pgQuery = _.cloneDeep sampleQuery
    pgQuery.table = testTable
    common.testTranslation franca.toPg, translations.pg, pgQuery
    common.testTranslation franca.toPg, translations.pg, pgQuery

  it 'translate a Postgres facet', () ->
    common.testTranslation franca.toPg, facetTrans.pg, sampleFacet

  it 'translate a Solr query', () ->
    common.testTranslation franca.toSolr, translations.solr, sampleQuery

  it 'translate multiple Solr queries', () ->
    common.testTranslation franca.toSolr, translations.solr, sampleQuery
    common.testTranslation franca.toSolr, translations.solr, sampleQuery

  it 'translate a Solr facet', () ->
    common.testTranslation franca.toSolr, facetTrans.solr, sampleFacet
