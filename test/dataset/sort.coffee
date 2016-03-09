require 'should'
rewire = require 'rewire'
data = require './data'
dataset = rewire '../../lib/dataset/index.js'

applySortOptions = dataset.__get__ 'applySortOptions'

describe 'Test sorting in memory data rows', () ->

  it 'should sort rows on string field', () ->
    rows = data.rows
    opts = sort: name: -1
    sortedRows = applySortOptions rows, opts
    sortedRows.length.should.eql rows.length
    nameVals = sortedRows.map (r) -> r.name
    nameVals.should.eql [
      'Foo', 'Foo', 'Foo',
      'Baz', 'Baz', 'Baz',
      'Bar', 'Bar', 'Bar'
    ]

  it 'should rows on numeric field', () ->
    rows = data.rows
    opts = sort: distance: 1
    sortedRows = applySortOptions rows, opts
    sortedRows.length.should.eql rows.length
    distVals = sortedRows.map (r) -> r.distance
    distVals.should.eql [1, 1, 1, 2, 2, 2, 3, 3, 3]

  it 'should rows on field with empty values', () ->
    rows = data.rows
    opts = sort: rating: 1
    sortedRows = applySortOptions rows, opts
    sortedRows.length.should.eql rows.length
    ratingVals = sortedRows.map (r) -> r.rating
    ratingVals.should.eql [
      25, 50, 60, 70, undefined, undefined,
      undefined, undefined, undefined
    ]
