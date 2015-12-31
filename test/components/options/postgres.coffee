require 'should'
_ = require 'lodash'
testCases = require './test-cases'

r = require('app-root-path').require
options = r 'lib/components/options'
common = r 'test/common'

testTable = 'pgTable'
translations =
  empty: FROM: testTable
  offset:
    FROM: testTable
    OFFSET: 100
  limit:
    FROM: testTable
    LIMIT: 10
  fields:
    FROM: testTable
    SELECT: 'volume, area, weight'
  sortArr:
    FROM: testTable
    'ORDER BY': 'name DESC, address ASC'

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

  it 'should throw error when table is not given', () ->
    options.toPg.bind(null, {}).should.throw()

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
