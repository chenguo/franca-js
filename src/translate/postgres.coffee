components = require '../components'

CLAUSES = ['SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY',
           'LIMIT', 'OFFSET']

combineComponents = (components) ->
  components.SELECT ?= '*'
  pgQuery = CLAUSES.reduce (str, c) ->
    val = components[c]
    if val? and val isnt ''
      str += ' ' if str isnt ''
      str += "#{c} #{val}"
    return str
  , ''
  return pgQuery

module.exports = (q) ->
  translated = combineComponents components.toPg q
  return translated
