common = require './common'

module.exports =
  TYPES: common.TYPES
  toMongo: require('./mongo-query').toNative
  toSolr: require('./solr-query').toNative
