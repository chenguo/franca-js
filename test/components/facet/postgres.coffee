_ = require 'lodash'
require 'should'

components = require '../../../lib/components'
common = require '../../common'
testCases = require './test-cases'

testTable = 'tab'
translations =
  basic:
    select: 'category, COUNT(category)'
    table: testTable
    groupBy: 'category'
    orderBy: 'COUNT(category) DESC'

  withLimit:
    select: 'category, COUNT(category)'
    table: testTable
    groupBy: 'category'
    orderBy: 'COUNT(category) DESC'
    limit: 100

  countAsc:
    select: 'category, COUNT(category)'
    table: testTable
    groupBy: 'category'
    orderBy: 'COUNT(category) ASC'

  byValue:
    select: 'category, COUNT(category)'
    table: testTable
    groupBy: 'category'
    orderBy: 'category ASC'

  valueDesc:
    select: 'category, COUNT(category)'
    table: testTable
    groupBy: 'category'
    orderBy: 'category DESC'

  withQuery:
    select: 'category, COUNT(category)'
    table: testTable
    where: "difficulty = 'high'"
    groupBy: 'category'
    orderBy: 'COUNT(category) DESC'


facetTester = (key) ->
  testCase = _.cloneDeep testCases[key]
  testCase.table = testTable
  expected = translations[key]
  common.testTranslation components.toPg, expected, testCase

describe 'Postgres facet query tests', () ->

  it 'translate basic facet query', () ->
   facetTester 'basic'

  it 'translate facet query with limit', () ->
   facetTester 'withLimit'

  it 'translate facet by count ascending query', () ->
   facetTester 'countAsc'

  it 'translate facet by value  query', () ->
   facetTester 'byValue'

  it 'translate facet by value descending query', () ->
   facetTester 'valueDesc'

  it 'translate facet query with additional filters', () ->
    facetTester 'withQuery'
