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
  null: "(*:* NOT name:[* TO *])"
  range: "age:[20 TO 30]"
  singleBoundRange: "age:[20 TO *]"


negatedTrans =
  basic: '(*:* NOT name:"Bill")'
  typeless: 'location:"Los Angeles"'
  multimatch: '(*:* NOT name:("Bill" OR "Will"))'
  null: "name:[* TO *]"
  range: "(*:* NOT age:[20 TO 30])"
  singleBoundRange: "(*:* NOT age:[20 TO *])"

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

  it 'should translate a single bound range query', () ->
    testQuery 'singleBoundRange'

  it 'should translate a negated single bound range query', () ->
    testNegatedQuery 'singleBoundRange'

  it 'should translate a regex query', () ->
    query = queries.regexp
    translated = q.toSolr query
    expected = 'name:/.*[wb]ill.*/'
    expected.should.be.equal translated

  it 'should translate a negated regex query', () ->
    query = _.clone queries.regexp
    query.negate = true
    translated = q.toSolr query
    expected = '(*:* NOT name:/.*[wb]ill.*/)'
    expected.should.be.equal translated
