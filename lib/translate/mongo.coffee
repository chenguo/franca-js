components = require '../components'

module.exports = (q) ->
  c = components.toMongo q
  translated =
    query: c.query
    options: c.options
  return translated
