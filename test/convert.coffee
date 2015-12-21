require 'should'

r = require('app-root-path').require
franca = r 'index'
common = require './common'


sampleQuery =
  options:
    offset: 50
    limit: 10
  query:
    type: franca.TYPES.Q
    field: 'price'
    range: lte: 100

translations =
  mongo:
    query:
      price: $lte: 100
    options:
      skip: 50
      limit: 10
  solr: 'q=price:[* TO 100]&start=50&rows=10'


describe 'Integration tests', () ->

  it 'translate to Mongo query', () ->
    common.testTranslation franca.toMongo, translations.mongo, sampleQuery

  it 'translate to Solr query', () ->
    common.testTranslation franca.toSolr, translations.solr, sampleQuery
