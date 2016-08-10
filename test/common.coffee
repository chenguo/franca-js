should = require 'should'
_ = require 'lodash'

negateQuery = (q) ->
  negated = _.cloneDeep q
  negated.negate = not q.negate
  return negated

translatedTester = (translated, expected) ->
  if translated instanceof Object
    translated.should.be.eql expected
  else
    should.equal translated, expected # in case the translated is null or undefined

testTranslation = (translator, expected, query) ->
  translated = translator query
  translatedTester translated, expected

module.exports =
  negateSpec: negateQuery

  testTranslation: testTranslation

  makeTester: (tests, translator, translations) ->
    return (key) ->
      query = tests[key]
      expected = translations[key]
      testTranslation translator, expected, query

  makeSpecifiedFieldTesterWithQuery: (tests, translator, translations, field) ->
    return (key) ->
      query = tests[key]
      specifiedVal = query[field]
      expected = translations[key]
      translated = translator specifiedVal, query
      translatedTester translated, expected

  makeNegateQueryTester: (queries, translator, negatedTranslations) ->
    return (key) ->
      query = negateQuery queries[key]
      expected = negatedTranslations[key]
      testTranslation translator, expected, query
