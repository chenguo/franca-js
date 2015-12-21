require 'should'
_ = require 'lodash'

negateQuery = (q) ->
  negated = _.cloneDeep q
  negated.negate = not q.negate
  return negated

testTranslation = (translator, expected, query) ->
  translated = translator query
  expected.should.be.eql translated

module.exports =
  negateSpec: negateQuery

  testTranslation: testTranslation

  makeTester: (tests, translator, translations) ->
    return (key) ->
      query = tests[key]
      expected = translations[key]
      testTranslation translator, expected, query

  makeNegateQueryTester: (queries, translator, negatedTranslations) ->
    return (key) ->
      query = negateQuery queries[key]
      expected = negatedTranslations[key]
      testTranslation translator, expected, query
