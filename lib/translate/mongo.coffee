r = require('app-root-path').require
components = r 'lib/components'

module.exports = (q) ->
  components = components.toMongo q
  translated =
    query: components.query
    options: components.options
  return translated
