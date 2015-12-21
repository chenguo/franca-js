require('coffee-script')
convert = require('./lib/convert')

module.exports = {
  query: require('./lib/query'),
  TYPES: require('./lib/query/common').TYPES,
  convert: convert,
  toMongo: convert.toMongo,
  toSolr: convert.toSolr
}
