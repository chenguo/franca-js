_ = require 'lodash'
require 'should'

components = require '../../../lib/components'
common = require '../../common'
testCases = require './test-cases'

testTable = 'tab'
translations =
  basic:
    SELECT: 'category, COUNT(category)'
    FROM: testTable
    'ORDER BY': 'COUNT(category) DESC'

  withLimit:
    SELECT: 'category, COUNT(category)'
    FROM: testTable
    'ORDER BY': 'COUNT(category) DESC'
    LIMIT: 100

  countAsc:
   SELECT: 'category, COUNT(category)'
   FROM: testTable
   'ORDER BY': 'COUNT(category) ASC'

  byValue:
   SELECT: 'category, COUNT(category)'
   FROM: testTable
   'ORDER BY': 'category ASC'

  valueDesc:
    SELECT: 'category, COUNT(category)'
    FROM: testTable
    'ORDER BY': 'category DESC'

  withQuery:
   SELECT: 'category, COUNT(category)'
   FROM: testTable
   WHERE: "difficulty = 'high'"
   'ORDER BY': 'COUNT(category) DESC'


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
