require 'should'
_ = require 'lodash'
r = require('app-root-path').require
common = require './common'
queries = require './queries'
q = r('index').query


translations =
  empty: '*:*'
  basic: 'name:"Bill"'
  typeless: '(*:* NOT location:"Los Angeles")'
  multimatch: 'name:("Bill" OR "Will")'
  null: '(*:* NOT name:[* TO *])'
  range: 'age:[20 TO 30]'
  rangeEx: 'age:([20 TO 30] NOT 20 NOT 30)'
  singleBoundRange: "age:[20 TO *]"
  regexp: 'name:/.*[wb]ill.*/'
translations.compound =
  '(' + translations.singleBoundRange + ' AND ' + translations.typeless + ')'
translations.nestedCompound =
  '(' + translations.basic + ' OR ' + translations.compound + ')'


negatedTrans =
  basic: '(*:* NOT name:"Bill")'
  typeless: 'location:"Los Angeles"'
  multimatch: '(*:* NOT name:("Bill" OR "Will"))'
  null: "name:[* TO *]"
  range: '(*:* NOT age:[20 TO 30])'
  rangeEx: '(*:* NOT age:([20 TO 30] NOT 20 NOT 30))'
  singleBoundRange: "(*:* NOT age:[20 TO *])"
  regexp: '(*:* NOT name:/.*[wb]ill.*/)'
negatedTrans.compound =
  '(' + negatedTrans.singleBoundRange + ' OR ' + negatedTrans.typeless + ')'
negatedTrans.nestedCompound =
  '(' + negatedTrans.basic + ' AND ' + negatedTrans.compound + ')'

testQuery = common.makeTester queries, q.toSolr, translations
testNegatedQuery = common.makeNegateTester queries, q.toSolr, negatedTrans

describe 'Solr query tests', () ->

  it 'should translate an empty query', () ->
    testQuery 'empty'

  it 'should throw error when negating an empty query', () ->
    negEmpty = negate: true
    q.toMongo.bind(null, negEmpty).should.throw()

  it 'should translate a simple query', () ->
    testQuery 'basic'

  it 'should translate a negated query', () ->
    testNegatedQuery 'basic'

  it 'should assume typeless queries are standard queries', () ->
    testQuery 'typeless'

  it 'should translate a multi-match query', () ->
    testQuery 'multimatch'

  it 'should translate a negated multi-match query', () ->
    testNegatedQuery 'multimatch'

  it 'should translate a null query', () ->
    testQuery 'null'

  it 'should translate a negated null query', () ->
    testNegatedQuery 'null'

  it 'should translate a range query', () ->
    testQuery 'range'

  it 'should translate a negated range query', () ->
    testNegatedQuery 'range'

  it 'should translate an exclusive range query', () ->
    testQuery 'rangeEx'

  it 'should translate a negated exclusive range query', () ->
    testNegatedQuery 'rangeEx'

  it 'should translate a single bound range query', () ->
    testQuery 'singleBoundRange'

  it 'should translate a negated single bound range query', () ->
    testNegatedQuery 'singleBoundRange'

  it 'should translate a regex query', () ->
    testQuery 'regexp'

  it 'should translate a negated regex query', () ->
    testNegatedQuery 'regexp'

  it 'should translate an anchored regex query ', () ->
    query =
      field: 'name'
      regexp: '/bill/'
    translated = q.toSolr query
    expected = 'name:/.*bill.*/'
    expected.should.be.equal translated

    query =
      field: 'name'
      regexp: '/^bill/'
    translated = q.toSolr query
    expected = 'name:/bill.*/'
    expected.should.be.equal translated

    query =
      field: 'name'
      regexp: '/bill$/'
    translated = q.toSolr query
    expected = 'name:/.*bill/'
    expected.should.be.equal translated

  it "should translate regex queries without explicit '/' characters", () ->
    query =
      field: 'name'
      regexp: '^bill'
    translated = q.toSolr query
    expected = 'name:/bill.*/'
    expected.should.be.equal translated

  it 'should translate regex queries with some JS style character classes', () ->
    query =
      field: 'address'
      regexp: '/^\\d{1,3} /'
    translated = q.toSolr query
    expected = 'address:/[0-9]{1,3} .*/'
    expected.should.be.equal translated

    query =
      field: 'address'
      regexp: '/^\\D{1,3} /'
    translated = q.toSolr query
    expected = 'address:/[^0-9]{1,3} .*/'
    expected.should.be.equal translated

    query =
      field: 'address'
      regexp: '/^\\w{3,5}$/'
    translated = q.toSolr query
    expected = 'address:/[A-Za-z0-9_]{3,5}/'
    expected.should.be.equal translated

  it 'should translate a compound query', () ->
    testQuery 'compound'

  it 'should translate a negated compound query', () ->
    testNegatedQuery 'compound'

  it 'should translate a nested compound query', () ->
    testQuery 'nestedCompound'

  it 'should translate a negated nested compound query', () ->
    testNegatedQuery 'nestedCompound'

  it 'should translate a raw query', () ->
    rawQuery =
      type: q.TYPES.RAW
      raw: translations.nestedCompound
    translated = q.toSolr rawQuery
    expected = translations.nestedCompound
    expected.should.be.eql translated
