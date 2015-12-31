_ = require 'lodash'
Qs = require 'qs'
r = require('app-root-path').require
components = r 'lib/components'

combineComponents = (components, encode) ->
  qStr = Qs.stringify components, encode: encode
  return qStr

module.exports = (q, encode=false) ->
  components = components.toSolr q
  translated = combineComponents components, encode
  return translated
