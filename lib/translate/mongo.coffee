_ = require 'lodash'
components = require '../components'

KEYS = ['query', 'options', 'pipeline', 'collection']

module.exports = (q) ->
  c = components.toMongo q
  translated = _.pick c, KEYS
  return translated
