require('coffee-script')
convert = require('./lib/convert')

module.exports = {
  query: require('./lib/query'),
  options: require('./lib/options'),
  TYPES: require('./lib/query/common').TYPES,
  convert: convert,
  toMongo: convert.toMongo,
  toPg: convert.toPg,
  toSolr: convert.toSolr
}
