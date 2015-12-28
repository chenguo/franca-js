require 'should'
options = require './options'

r = require('app-root-path').require
toPg = r('lib/options').toPg
common = r 'test/common'

translations =
  empty: ''
  offset: 'OFFSET 100'
  limit: 'LIMIT 10'
  sortArr: 'ORDER BY name DESC, address ASC'

translations.sortObj = translations.sortArr
translations.combined =
  translations.sortArr + ' ' + translations.offset + ' ' + translations.limit

testOptions = common.makeTester options, toPg, translations

describe 'Postgres options tests', () ->

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
