_ = require 'lodash'
require 'should'

r = require('app-root-path').require
components = r 'lib/components'
common = r 'test/common'
testCases = require './test-cases'


translations =
  basic:
    'facet.field': 'category'
    'facet.sort': 'count'
    q: '*:*'

  withLimit:
    'facet.field': 'category'
    'facet.sort': 'count'
    'facet.limit': 100
    q: '*:*'

  byValue:
    'facet.field': 'category'
    'facet.sort': 'index'
    q: '*:*'

  withQuery:
    'facet.field': 'category'
    'facet.sort': 'count'
    q: 'difficulty:"high"'

facetTester = common.makeTester testCases, components.toSolr, translations

describe 'Solr facet query tests', () ->

  it 'translate basic facet query', () ->
   facetTester 'basic'

  it 'translate facet query with limit', () ->
   facetTester 'withLimit'

  it 'translate facet by count ascending query', () ->
   facetTester.bind(null,'countAsc').should.throw()

  it 'translate facet by value  query', () ->
   facetTester 'byValue'

  it 'translate facet by value descending query', () ->
   facetTester.bind(null,'valueDesc').should.throw()

  it 'translate facet query with additional filters', () ->
    facetTester 'withQuery'
