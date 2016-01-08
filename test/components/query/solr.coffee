require 'should'
_ = require 'lodash'
testCases = require './test-cases'
TYPES = require('../../../lib/common').TYPES
query = require '../../../lib/components/query'
common = require '../../common'


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
  noAnchorRegexp: 'name:/.*bill.*/'
  startAnchorRegexp: 'name:/bill.*/'
  endAnchorRegexp: 'name:/.*bill/'
  noSlashRegexp: 'name:/bill.*/'
  numRegexp: 'address:/[0-9]{1,3} .*/'
  nonNumRegexp: 'address:/[^0-9]{1,3} .*/'
  wordCharsRegexp: 'address:/[A-Za-z0-9_]{3,5}/'
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


testQuery = common.makeTester testCases, query.toSolr, translations
testNegatedQuery = common.makeNegateQueryTester testCases, query.toSolr, negatedTrans


describe 'Solr query tests', () ->

  it 'should translate an empty query', () ->
    testQuery 'empty'

  it 'should throw error when negating an empty query', () ->
    negEmpty = negate: true
    query.toSolr.bind(null, negEmpty).should.throw()

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
    testQuery 'noAnchorRegexp'
    testQuery 'startAnchorRegexp'
    testQuery 'endAnchorRegexp'

  it "should translate regex queries without explicit '/' characters", () ->
    testQuery 'noSlashRegexp'

  it 'should translate regex queries with some JS style character classes', () ->
    testQuery 'numRegexp'
    testQuery 'nonNumRegexp'
    testQuery 'wordCharsRegexp'

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
      type: TYPES.RAW
      raw: translations.nestedCompound
    translated = query.toSolr rawQuery
    expected = translations.nestedCompound
    expected.should.be.eql translated
