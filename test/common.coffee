require 'should'
_ = require 'lodash'

negateQuery = (q) ->
  negated = _.cloneDeep q
  negated.negate = not q.negate
  return negated

module.exports =
  negateSpec: negateQuery

  makeTester: (tests, translator, translations) ->
    return (key) ->
      test = tests[key]
      expected = translations[key]
      translated = translator test
      expected.should.be.eql translated

  makeNegateQueryTester: (queries, translator, negatedTranslations) ->
    return (key) ->
      query = negateQuery queries[key]
      expected = negatedTranslations[key]
      translated = translator query
      expected.should.be.eql translated
