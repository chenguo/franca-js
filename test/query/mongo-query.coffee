require 'should'
_ = require 'lodash'
r = require('app-root-path').require
common = require './common'
queries = require './queries'
q = r('index').query

# Translations
translations =
  basic:
    name: 'Bill'
  typeless:
    location: $ne: 'Los Angeles'
  multimatch:
    name: $in: ['Bill', 'Will']
  null:
    $or: [
      name: null
    , name: $exists: false
    ]
  range:
    $and: [
      age: $gte: 20
    , age: $lte: 30
    ]
  singleBoundRange:
    age: $gte: 20
translations.compound =
  $and: [translations.singleBoundRange, translations.typeless]
translations.nestedCompound =
  $or: [translations.basic, translations.compound]

# Negated translations
negatedTrans =
  basic:
    name: $ne: 'Bill'
  typeless:
    location: 'Los Angeles'
  multimatch:
    name: $nin: ['Bill', 'Will']
  null:
    $and: [
      name: $ne: null
    , name: $exists: true
    ]
  range:
    $or: [
      age: $lt: 20
    , age: $gt: 30
    ]
  singleBoundRange:
    age: $lt: 20
negatedTrans.compound =
  $or: [negatedTrans.singleBoundRange, negatedTrans.typeless]
negatedTrans.nestedCompound =
  $and: [negatedTrans.basic, negatedTrans.compound]


testQuery = common.makeTester queries, q.toMongo, translations
testNegatedQuery = common.makeNegateTester queries, q.toMongo, negatedTrans

describe 'Mongo query tests', () ->

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
    translated = q.toMongo query
    translated.should.have.property('name').and.be.instanceof RegExp
    translated.name.test('bill').should.equal true
    translated.name.test('WILL').should.equal true
    translated.name.test('fill').should.equal false

  it 'should translate a negated regex query', () ->
    query = _.clone queries.regexp
    query.negate = true
    translated = q.toMongo query
    translated.should.have.property 'name'
    translated.name.should.have.property('$not').and.be.instanceof RegExp
    translated.name.$not.test('bill').should.equal true
    translated.name.$not.test('WILL').should.equal true
    translated.name.$not.test('fill').should.equal false

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
      raw:
        translations.nestedCompound
    translated = q.toMongo rawQuery
    expected = translations.nestedCompound
    expected.should.be.eql translated
