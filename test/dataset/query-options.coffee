require 'should'
evalQuery = require('../../lib/dataset').query
data = require './data'

describe 'Test in-memory query options', () ->

  it 'apply sort option', () ->
    query =
      query:
        field: 'name'
        match: 'Foo'
      options:
        sort: distance: -1
    result = evalQuery data.rows, query
    result[0].should.eql data.foo3
    result[1].should.eql data.foo2
    result[2].should.eql data.foo1

  it 'apply multiple sorts', () ->
    query =
      options:
        sort: [['distance', -1], ['name', -1]]
    result = evalQuery data.rows, query
    result[0].should.eql data.foo3
    result[1].should.eql data.baz3
    result[2].should.eql data.bar3
    result[3].should.eql data.foo2
    result[4].should.eql data.baz2
    result[5].should.eql data.bar2
    result[6].should.eql data.foo1
    result[7].should.eql data.baz1
    result[8].should.eql data.bar1

  it 'apply offset option', () ->
    query = options: offset: 5
    result = evalQuery data.rows, query
    result.length.should.equal data.rows.length - query.options.offset
    result[0].should.eql data.rows[5]
    result[3].should.eql data.rows[8]

  it 'apply out-of-bounds offset option', () ->
    query = options: offset: 10
    result = evalQuery data.rows, query
    result.length.should.equal 0

  it 'apply limit option', () ->
    query = options: limit: 5
    result = evalQuery data.rows, query
    result.length.should.equal query.options.limit
    result[0].should.eql data.rows[0]
    result[3].should.eql data.rows[3]
    result[4].should.eql data.rows[4]

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
    result[0].should.eql data.rows[5]
    result[1].should.eql data.rows[6]
    result[2].should.eql data.rows[7]

  it 'apply offset and out-of-bounds limit options', () ->
    query =
      options:
        offset: 8
        limit: 5
    result = evalQuery data.rows, query
    result.length.should.equal data.rows.length - query.options.offset
    result[0].should.eql data.rows[8]
