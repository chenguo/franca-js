require 'should'
TYPES = require('../../lib/common').TYPES
evalQuery = require('../../lib/dataset').query
data = require './data'

describe 'Test in-memory query evaluation', () ->

  it 'evaluate an empty query', () ->
    query = {}
    result = evalQuery data.rows, query
    result.should.eql data.rows

  it 'evaluate a basic query', () ->
    query =
      query:
        field: 'name'
        match: 'Foo'
    result = evalQuery data.rows, query
    result.length.should.equal 3
    result.should.containEql data.foo1
    result.should.containEql data.foo2
    result.should.containEql data.foo3
    result.should.not.containEql data.bar1
    result.should.not.containEql data.baz2
    result.should.not.containEql data.baz3

  it 'evalute a compound query', () ->
    query =
      query:
        type: TYPES.OR
        queries: [
          field: 'name'
          match: 'Foo'
        ,
          field: 'name'
          match: 'Bar'
        ]
    result = evalQuery data.rows, query
    result.should.containEql data.foo1
    result.should.containEql data.foo3
    result.should.containEql data.bar1
    result.should.containEql data.bar2
    result.should.not.containEql data.baz1
    result.should.not.containEql data.baz2
