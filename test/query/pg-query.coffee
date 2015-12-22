require 'should'
_ = require 'lodash'
r = require('app-root-path').require
queries = require './queries'
types = r('lib/query').TYPES
toPg = r('lib/query').toPg
common = r 'test/common'


translations =
  empty: ''
  basic: "name = 'Bill'"
  typeless: "location != 'Los Angeles'"
  multimatch: "name IN ('Bill', 'Will')"
  null: 'name IS NULL'
  range: 'age BETWEEN 20 AND 30'
  rangeEx: 'age > 20 AND age < 30'
  singleBoundRange: 'age >= 20'

negatedTrans =
  basic: "name != 'Bill'"
  typeless: "location = 'Los Angeles'"
  multimatch: "name NOT IN ('Bill', 'Will')"
  null: 'name IS NOT NULL'
  range: 'age NOT BETWEEN 20 AND 30'
  rangeEx: 'age <= 20 OR age >= 30'
  singleBoundRange: 'age < 20'

testQuery = common.makeTester queries, toPg, translations
testNegatedQuery = common.makeNegateQueryTester queries, toPg, negatedTrans

describe 'Postgres query tests', () ->

  it 'should translate an empty query', () ->
    testQuery 'empty'

  it 'should throw error when negating an empty query', () ->
    negEmpty = negate: true
    toPg.bind(null, negEmpty).should.throw()

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
