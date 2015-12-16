require 'should'
_ = require 'lodash'

module.exports =
  negateSpec: (q) ->
    negated =
      query: _.cloneDeep q.query
      translated: q.negTranslated
    negated.query.negate = not negated.query.negate
    return negated

  testQuery: (q, translator) ->
    query = q.query
    expected = q.translated
    translated = translator query
    expected.should.be.eql translated
