require 'should'
_ = require 'lodash'

negateQuery = (q) ->
  negated = _.cloneDeep q
  negated.negate = not q.negate
  return negated

module.exports =
  negateSpec: (q) ->

  makeTester: (queries, translator, translations) ->
    return (key) ->
      query = queries[key]
      expected = translations[key]
      translated = translator query
      expected.should.be.eql translated

  makeNegateTester: (queries, translator, negatedTranslations) ->
    return (key) ->
      query = negateQuery queries[key]
      expected = negatedTranslations[key]
      translated = translator query
      expected.should.be.eql translated
