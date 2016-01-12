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

  it 'apply offset option', () ->
    query = options: offset: 5
    result = evalQuery data.rows, query
    result.length.should.equal data.rows.length - query.options.offset
    result[0].should.equal data.rows[5]
    result[3].should.equal data.rows[8]

  it 'apply out-of-bounds offset option', () ->
    query = options: offset: 10
    result = evalQuery data.rows, query
    result.length.should.equal 0

  it 'apply limit option', () ->
    query = options: limit: 5
    result = evalQuery data.rows, query
    result.length.should.equal query.options.limit
    result[0].should.equal data.rows[0]
    result[3].should.equal data.rows[3]
    result[4].should.equal data.rows[4]

  it 'apply out-of-bounds limit option', () ->
    query = options: limit: 100
    result = evalQuery data.rows, query
    result.should.eql data.rows

  it 'apply offset and limit options', () ->
    query =
      options:
        limit: 3
        offset: 5
    result = evalQuery data.rows, query
    result.length.should.equal query.options.limit
    result[0].should.equal data.rows[5]
    result[1].should.equal data.rows[6]
    result[2].should.equal data.rows[7]

  it 'apply offset and out-of-bounds limit options', () ->
    query =
      options:
        offset: 8
        limit: 5
    result = evalQuery data.rows, query
    result.length.should.equal data.rows.length - query.options.offset
    result[0].should.equal data.rows[8]
