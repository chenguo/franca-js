mongo = require './convert-mongo'
solr = require './convert-solr'

module.exports =
  toMongo: mongo.toMongo
  toSolr: solr.toSolr
