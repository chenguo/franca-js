require 'should'
_ = require 'lodash'
TYPES = require('../../lib/common').TYPES
makePredicate = require '../../lib/dataset/make-predicate'
data = require './data'

queries =
  empty: {}

  value:
    field: 'distance'
    match: 3

  matchIn:
    field: 'name'
    match: ['Foo', 'Bar']

  null:
    field: 'rating'
    null: true

  nonNull:
    field: 'rating'
    null: false

  range:
    field: 'rating'
    range:
      gte: 50
      lte: 70

  negRange:
    field: 'rating'
    range:
      gte: 50
      lte: 70
    negate: true

  rangeEx:
    field: 'rating'
    range:
      gt: 50
      lt: 70

  negRangeEx:
    field: 'rating'
    range:
      gt: 50
      lt: 70
    negate: true

  singleBoundRange:
    field: 'rating'
    range: gt: 50

  negSingleBoundRange:
    field: 'rating'
    range: gt: 50
    negate: true

  regexp:
    field: 'name'
    regexp: /^B/

expected =
  empty:
    match: ['foo3', 'bar1', 'baz2']

  value:
    match: ['foo3', 'bar3', 'baz3']
    nonMatch: ['foo1', 'foo2', 'baz1']

  matchIn:
    match: ['foo1', 'foo2', 'foo3', 'bar1', 'bar2', 'bar3']
    nonMatch: ['baz1', 'baz2', 'baz3']

  null:
    match: ['foo2', 'bar1', 'baz1']
    nonMatch: ['foo1', 'bar2', 'baz2', 'baz3']

  nonNull:
    match: ['foo1', 'bar2', 'baz2', 'baz3']
    nonMatch: ['foo2', 'foo3', 'bar3', 'baz1']

  range:
    match: ['foo1', 'baz2', 'baz3']
    nonMatch: ['foo2', 'bar2', 'baz1']

  negRange:
    match: ['bar2']
    nonMatch: ['foo1', 'foo2', 'bar3', 'baz1', 'baz2']

  rangeEx:
    match: ['baz2']
    nonMatch: ['foo1', 'bar2', 'baz3']

  negRangeEx:
    match: ['foo1', 'bar2', 'baz3']
    nonMatch: ['foo2', 'baz1', 'baz2']

  singleBoundRange:
    match: ['baz2', 'baz3']
    nonMatch: ['foo1', 'foo2', 'bar2', 'bar3']

  negSingleBoundRange:
    match: ['foo1', 'bar2']
    nonMatch: ['foo2', 'bar1', 'baz2']

  regexp:
    match: ['bar1', 'baz2']
    nonMatch: ['foo1', 'foo2', 'foo3']

testEval = (test, negate) ->
  matches = expected[test].match or []
  nonMatches = expected[test].nonMatch or []
  testQuery queries[test], matches, nonMatches

testNegateEval = (test) ->
  query = _.cloneDeep queries[test]
  query.negate = not query.negate
  matches = expected[test].nonMatch or []
  nonMatches = expected[test].match or []
  testQuery query, matches, nonMatches

testQuery = (query, matches, nonMatches) ->
  pred = makePredicate query
  matches.forEach (rowKey) ->
    true.should.equal pred data[rowKey]
  nonMatches.forEach (rowKey) ->
    false.should.equal pred data[rowKey]

describe 'Query predicate tests', () ->

  it 'evaluate empty query', () ->
    testEval 'empty'

  it 'evaluate value matching query', () ->
    testEval 'value'

  it 'evalute negated value matching query', () ->
    testNegateEval 'value'

  it 'evaluate a multi-match query', () ->
    testEval 'value'

  it 'evaluate a negated multi-match query', () ->
    testNegateEval 'value'

  it 'evaluate a null query', () ->
    testEval 'null'

  it 'evaluate a negated null query', () ->
    testNegateEval 'null'

  it 'evaluate a non-null query', () ->
    testEval 'nonNull'

  it 'evaluate a negated non-null query', () ->
    testNegateEval 'nonNull'

  it 'evaluate a range query', () ->
    testEval 'range'

  it 'evaluate a negated range query', () ->
    testEval 'negRange'

  it 'evaluate an exclusive range query', () ->
    testEval 'rangeEx'

  it 'evaluate a negated exclusive range query', () ->
    testEval 'negRangeEx'

  it 'evaluate a single bound range query', () ->
    testEval 'singleBoundRange'

  it 'evaluate a negated single bound range query', () ->
    testEval 'negSingleBoundRange'

  it 'evaluate a regex query', () ->
    testEval 'regexp'

  it 'evaluate a negated regex query', () ->
    testNegateEval 'regexp'

  it 'evaluate AND compound query', () ->
    query =
      type: TYPES.AND
      queries: [
        field: 'name'
        match: 'Foo'
      ,
        field: 'distance'
        match: 3
      ]
    pred = makePredicate query
    true.should.equal pred data.foo3
    false.should.equal pred data.bar3
    false.should.equal pred data.foo1

  it 'evalute OR compound query', () ->
    query =
      type: TYPES.OR
      queries: [
        field: 'name'
        match: 'Foo'
      ,
        field: 'distance'
        match: 3
      ]
    pred = makePredicate query
    true.should.equal pred data.foo3
    true.should.equal pred data.bar3
    true.should.equal pred data.foo1
    false.should.equal pred data.baz2
    false.should.equal pred data.bar1
