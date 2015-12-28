require 'should'
options = require './options'

r = require('app-root-path').require
mongoOpts = r 'lib/options/mongo-options'
common = r 'test/common'


translations =
  empty: {}
  offset: skip: 100
  limit: limit: 10
  sortArr: sort: [['name', -1], ['address', 1]]

translations.sortObj = translations.sortArr
translations.combined =
  skip: 100
  limit: 10
  sort: translations.sortArr.sort


testOptions = common.makeTester options, mongoOpts.toMongo, translations

describe 'Mongo options tests', () ->

  it 'should translate empty options', () ->
    testOptions 'empty'

  it 'should translate an offset option', () ->
    testOptions 'offset'

  it 'should translate a limit options', () ->
    testOptions 'limit'

  it 'should translate sort options given as array', () ->
    testOptions 'sortArr'

  it 'should translate sort options given as object', () ->
    testOptions 'sortObj'

  it 'should translate combined options', () ->
    testOptions 'combined'
