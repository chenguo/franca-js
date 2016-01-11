require 'should'
data = require './data'
dataset = require '../../lib/dataset'


describe 'Test in-memory data facet generation', () ->

  it 'should generate empty facets on empty data', () ->
    rows = []
    query = {}
    results = dataset.facets rows, query
    results.length.should.equal 0

  it 'should generate facets on a field', () ->
    query = facet: field: 'name'
    results = dataset.facets data.rows, query
    results.length.should.equal 3
    results.should.containEql value: 'Foo', count: 3
    results.should.containEql value: 'Bar', count: 3
    results.should.containEql value: 'Baz', count: 3

  it 'should generate facets sorted by value', () ->
    query =
      facet:
        field: 'name'
        sort: 'value'
    results = dataset.facets data.rows, query
    results.length.should.equal 3
    results[0].value.should.equal 'Bar'
    results[1].value.should.equal 'Baz'
    results[2].value.should.equal 'Foo'

  it 'should generate facets with sort direction', () ->
    query =
      facet:
        field: 'name'
        sort: value: -1
    results = dataset.facets data.rows, query
    results.length.should.equal 3
    results[0].value.should.equal 'Foo'
    results[1].value.should.equal 'Baz'
    results[2].value.should.equal 'Bar'

  it 'should generate facets with a query', () ->
    query =
      facet:
        field: 'distance'
      query:
        field: 'name'
        match: 'Foo'
    results = dataset.facets data.rows, query
    results.length.should.equal 3
    results.should.containEql value: 1, count: 1
    results.should.containEql value: 2, count: 1
    results.should.containEql value: 3, count: 1
