require 'should'
_ = require 'lodash'
testCases = require './test-cases'
TYPES = require('../../../lib/common').TYPES
query = require '../../../lib/components/query'
common = require '../../common'


translations =
  empty: ''
  basic: "name = 'Bill'"
  typeless: "location != 'Los Angeles'"
  multimatch: "name IN ('Bill', 'Will')"
  null: 'name IS NULL'
  range: 'age BETWEEN 20 AND 30'
  rangeEx: 'age > 20 AND age < 30'
  singleBoundRange: 'age >= 20'
  regexp: "name ~* '[wb]ill'"
  noAnchorRegexp: "name ~ 'bill'"
  startAnchorRegexp: "name ~ '^bill'"
  endAnchorRegexp: "name ~ 'bill$'"
  noSlashRegexp: "name ~ '^bill'"
  numRegexp: "address ~ '^\\d{1,3} '"
  nonNumRegexp: "address ~ '^\\D{1,3} '"
  wordCharsRegexp: "address ~ '^\\w{3,5}$'"
translations.compound =
  '(' + translations.singleBoundRange + ' AND ' + translations.typeless + ')'
translations.nestedCompound =
  '(' + translations.basic + ' OR ' +  translations.compound + ')'


negatedTrans =
  basic: "name != 'Bill'"
  typeless: "location = 'Los Angeles'"
  multimatch: "name NOT IN ('Bill', 'Will')"
  null: 'name IS NOT NULL'
  range: 'age NOT BETWEEN 20 AND 30'
  rangeEx: 'age <= 20 OR age >= 30'
  singleBoundRange: 'age < 20'
  regexp: "name !~* '[wb]ill'"
negatedTrans.compound =
  '(' + negatedTrans.singleBoundRange + ' OR ' + negatedTrans.typeless + ')'
negatedTrans.nestedCompound =
  '(' + negatedTrans.basic + ' AND ' + negatedTrans.compound + ')'

# Negated null queries
translations.nonNull = negatedTrans.null
negatedTrans.nonNull = translations.null


testQuery = common.makeTester testCases, query.toPg, translations
testNegatedQuery = common.makeNegateQueryTester testCases, query.toPg, negatedTrans

describe 'Postgres query tests', () ->

  it 'should translate an empty query', () ->
    testQuery 'empty'

  it 'should throw error when negating an empty query', () ->
    negEmpty = negate: true
    query.toPg.bind(null, negEmpty).should.throw()

  it 'should translate a simple query', () ->
    testQuery 'basic'

  it 'should translate a query with single quote', () ->
    q =
      field: 'name'
      match: "Bobby's Coffee"
    expected  = "name = 'Bobby''s Coffee'"
    common.testTranslation query.toPg, expected, q

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

  it 'should translate a non-null query', () ->
    testQuery 'nonNull'

  it 'should translate a negated non-null query', () ->
    testQuery 'nonNull'

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

  it 'should translate a raw query', () ->
    raw = 'select * from mytable'
    rawQuery =
      type: TYPES.RAW
      raw: raw
    translated = query.toPg rawQuery
    raw.should.be.eql translated

  it 'should translate a nested raw query', () ->
    rawQuery =
      type: TYPES.OR
      queries: [
        testCases.basic
      ,
        type: TYPES.RAW
        raw: translations.compound
      ]
    translated = query.toPg rawQuery
    expected = translations.nestedCompound
    expected.should.be.eql translated
