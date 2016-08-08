require 'should'
_ = require 'lodash'
testCases = require './test-cases'

options = require '../../../lib/components/options'
common = require '../../common'

testTable = 'pgTable'
translations =
  empty: table: testTable
  offset:
    table: testTable
    offset: 100
  limit:
    table: testTable
    limit: 10
  fields:
    table: testTable
    select: 'volume, area, weight'
  sortArr:
    table: testTable
    orderBy: 'name DESC, address ASC'

translations.sortObj = translations.sortArr
translations.combined =
  _.merge {}, translations.sortArr, translations.fields, translations.limit, translations.offset

testOptions = (key) ->
  testOpts = _.cloneDeep testCases[key]
  testOpts.table = testTable
  common.testTranslation options.toPg, translations[key], testOpts

describe 'Postgres options tests', () ->

  it 'should translate empty options', () ->
    testOptions 'empty'

  it 'should translate an offset option', () ->
    testOptions 'offset'

  it 'should translate a limit options', () ->
    testOptions 'limit'

  it 'should translate a query for a subset of fields', () ->
    testOptions 'fields'

  it 'should translate sort options given as array', () ->
    testOptions 'sortArr'

  it 'should translate sort options given as object', () ->
    testOptions 'sortObj'

  it 'should translate combined options', () ->
    testOptions 'combined'
