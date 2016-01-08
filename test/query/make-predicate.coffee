require 'should'
TYPES = require('../../lib/common').TYPES
makePredicate = require '../../lib/query/make-predicate'
data = require './data'

describe 'Query predicate tests', () ->

  it 'evaluate empty query', () ->
    query = {}
    pred = makePredicate query
    true.should.equal pred data.foo3
    true.should.equal pred data.bar1
    true.should.equal pred data.baz2

  it 'evaluate value matching query', () ->
    query =
      field: 'distance'
      match: 3
    pred = makePredicate query
    true.should.equal pred data.foo3
    true.should.equal pred data.bar3
    false.should.equal pred data.baz1

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
