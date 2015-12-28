mongo = require './convert-mongo'
pg = require './convert-pg'
solr = require './convert-solr'

module.exports =
  toMongo: mongo.toMongo
  toPg: pg.toPg
  toSolr: solr.toSolr
