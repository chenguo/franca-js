require 'should'
_ = require 'lodash'
testCases = require './test-cases'

options = require '../../../lib/components/options'
common = require '../../common'


translations =
  empty: {}
  offset: skip: 100
  limit: limit: 10
  fields:
    fields:
      volume: 1
      area: 1
      weight: 1
  sortArr: sort: [['name', -1], ['address', 1]]

translations.sortObj = translations.sortArr
translations.combined =
  skip: 100
  limit: 10
  fields: translations.fields.fields
  sort: translations.sortArr.sort


testOptions = common.makeTester testCases, options.toMongo, translations

describe 'Mongo options tests', () ->

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

  it 'should translate a collection specification', () ->
    colQuery =
      table: 'myCollection'
    expected = collection: 'myCollection'
    common.testTranslation options.toMongo, expected, colQuery
