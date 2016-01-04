_ = require 'lodash'
Qs = require 'qs'
components = require '../components'

combineComponents = (components, encode) ->
  qStr = Qs.stringify components, encode: encode
  return qStr

module.exports = (q, encode=false) ->
  c = components.toSolr q
  translated = combineComponents c, encode
  return translated
