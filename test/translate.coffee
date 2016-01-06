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


describe 'General integration tests', () ->

  it 'translate to Mongo query', () ->
    common.testTranslation franca.toMongo, translations.mongo, sampleQuery

  it 'translate multiple Mongo queries', () ->
    common.testTranslation franca.toMongo, translations.mongo, sampleQuery
    common.testTranslation franca.toMongo, translations.mongo, sampleQuery

  it 'translate to Postgres query', () ->
    pgQuery = _.cloneDeep sampleQuery
    pgQuery.table = testTable
    common.testTranslation franca.toPg, translations.pg, pgQuery

  it 'translate multiple Postgres queries', () ->
    pgQuery = _.cloneDeep sampleQuery
    pgQuery.table = testTable
    common.testTranslation franca.toPg, translations.pg, pgQuery
    common.testTranslation franca.toPg, translations.pg, pgQuery

  it 'translate to Solr query', () ->
    common.testTranslation franca.toSolr, translations.solr, sampleQuery

  it 'translate multiple Solr queries', () ->
    common.testTranslation franca.toSolr, translations.solr, sampleQuery
    common.testTranslation franca.toSolr, translations.solr, sampleQuery
