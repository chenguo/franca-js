common = require './common'

module.exports =
  TYPES: common.TYPES
  toMongo: require('./mongo-query').toNative
  toPg: require('./pg-query').toNative
  toSolr: require('./solr-query').toNative
