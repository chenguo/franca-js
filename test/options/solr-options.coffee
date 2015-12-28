require 'should'
options = require './options'

r = require('app-root-path').require
toSolr = r('lib/options').toSolr
common = r 'test/common'


translations =
  empty: {}
  offset: start: 100
  limit: rows: 10
  sortArr: sort: 'name+desc,address+asc'

translations.sortObj = translations.sortArr
translations.combined =
  start: 100
  rows: 10
  sort: translations.sortArr.sort


testOptions = common.makeTester options, toSolr, translations

describe 'Solr options tests', () ->

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
