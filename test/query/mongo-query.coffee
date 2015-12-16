require 'should'
_ = require 'lodash'
r = require('app-root-path').require
Query = r('index').query

TYPES = Query.TYPES

negateSpec = (q) ->
  q.query = _.cloneDeep q.query
  q.query.negate = not q.query.negate
  q.translated = q.negTranslated
  return q

testQuery = (q) ->
  query = q.query
  expected = q.translated
  translated = Query.toMongo query
  expected.should.be.eql translated


describe 'Mongo query tests', () ->

  basicQuerySpec =
    query:
      type: TYPES.Q
      field: 'name'
      match: 'Bill'
    translated:
      name: 'Bill'
    negTranslated:
      name: $ne: 'Bill'

  it 'should translate simple query', () ->
    testQuery basicQuerySpec

  it 'should translate a negated query', () ->
    testQuery negateSpec basicQuerySpec

  typelessQuerySpec =
    query:
      field: 'location'
      match: 'Los Angeles'
      negate: true
    translated:
      location: $ne: 'Los Angeles'
    negTranslated:
      location: 'Los Angeles'

  it 'should assume typeless queries are standard queries', () ->
    testQuery typelessQuerySpec

  nullQuerySpec =
    query:
      type: TYPES.Q
      field: 'name'
      null: true
    translated:
      $or: [
        name: null
      , name: $exists: false
      ]
    negTranslated:
      $and: [
        name: $ne: null
      , name: $exists: true
      ]

  it 'should translate a null query', () ->
    testQuery nullQuerySpec

  it 'should translate a negated null query', () ->
    testQuery negateSpec nullQuerySpec

  rangeQuerySpec =
    query:
      type: TYPES.Q
      field: 'age'
      range:
        min: 20
        max: 30
    translated:
      $and: [
        age: $gte: 20
      , age: $lte: 30
      ]
    negTranslated:
      $or: [
        age: $lt: 20
      , age: $gt: 30
      ]

  singleBoundRangeQuerySpec =
    query:
      type: TYPES.Q
      field: 'age'
      range: min: 20
    translated:
      age: $gte: 20
    negTranslated:
      age: $lt: 20

  it 'should translate a range query', () ->
    testQuery rangeQuerySpec

  it 'should translate a negated range query', () ->
    testQuery negateSpec rangeQuerySpec

  it 'should translate a single bound range query', () ->
    testQuery singleBoundRangeQuerySpec

  it 'should translate a negated single bound range query', () ->
    testQuery negateSpec singleBoundRangeQuerySpec

  regexQuery =
    type: TYPES.Q
    field: 'name'
    regexp: '[wb]ill'
    regFlags: 'i'

  it 'should translate a regex query', () ->
    query = regexQuery
    translated = Query.toMongo query
    translated.should.have.property('name').and.be.instanceof RegExp
    translated.name.test('bill').should.equal true
    translated.name.test('WILL').should.equal true
    translated.name.test('fill').should.equal false

  it 'should translate a negated regex query', () ->
    query = _.clone regexQuery
    query.negate = true
    translated = Query.toMongo query
    translated.should.have.property 'name'
    translated.name.should.have.property('$not').and.be.instanceof RegExp
    translated.name.$not.test('bill').should.equal true
    translated.name.$not.test('WILL').should.equal true
    translated.name.$not.test('fill').should.equal false

  compoundQuerySpec =
    query:
      type: TYPES.AND
      queries: [
        singleBoundRangeQuerySpec.query
      , typelessQuerySpec.query
      ]
    translated:
      $and: [
        singleBoundRangeQuerySpec.translated
      , typelessQuerySpec.translated
      ]
    negTranslated:
      $or: [
        singleBoundRangeQuerySpec.negTranslated
      , typelessQuerySpec.negTranslated
      ]

  it 'should translate a compound query', () ->
    testQuery compoundQuerySpec

  it 'should translate a negated compound query', () ->
    testQuery negateSpec compoundQuerySpec

  nestedCompoundQuerySpec =
    query:
      type: TYPES.OR
      queries: [
        basicQuerySpec.query
      , compoundQuerySpec.query
      ]
    translated:
      $or: [
        basicQuerySpec.translated
      , compoundQuerySpec.translated
      ]
    negTranslated:
      $and: [
        basicQuerySpec.negTranslated
      , compoundQuerySpec.negTranslated
      ]

  it 'should translate a nested compound query', () ->
    testQuery nestedCompoundQuerySpec

  it 'should translate a negated nested compound query', () ->
    testQuery negateSpec nestedCompoundQuerySpec

  rawQuerySpec =
    query:
      type: TYPES.RAW
      raw:
        nestedCompoundQuerySpec.translated
    translated:
        nestedCompoundQuerySpec.translated

  it 'should translate a nested compound query', () ->
    testQuery rawQuerySpec
