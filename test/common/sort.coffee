require 'should'
common = require '../../lib/common'

describe 'Test helper functions for sort options', () ->

  it 'determine ascending option values', () ->
    true.should.equal common.isAscVal 1
    true.should.equal common.isAscVal '1'
    true.should.equal common.isAscVal 'asc'
    true.should.equal common.isAscVal 'ascending'
    false.should.equal common.isAscVal null
    false.should.equal common.isAscVal 0
    false.should.equal common.isAscVal 'desc'

  it 'determine descending option values', () ->
    true.should.equal common.isDescVal -1
    true.should.equal common.isDescVal '-1'
    true.should.equal common.isDescVal 'desc'
    true.should.equal common.isDescVal 'descending'
    false.should.equal common.isDescVal null
    false.should.equal common.isDescVal 0
    false.should.equal common.isDescVal '1'

  ASC = 'a'
  DESC = 'b'

  it 'format sort values as specified', () ->
    formatter = common.makeSortValueFormatter ASC, DESC
    ASC.should.equal formatter 1
    ASC.should.equal formatter 'ASC'
    DESC.should.equal formatter 'descending'
    DESC.should.equal formatter 'deSCEndINg'

  it 'throw error for invalid sort values', () ->
    formatter = common.makeSortValueFormatter ASC, DESC
    formatter.bind(null, 0).should.throw()
    formatter.bind(null, null).should.throw()
    formatter.bind(null, 'banana').should.throw()
