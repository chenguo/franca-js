_ = require 'lodash'
require 'should'

components = require '../../../lib/components'
common = require '../../common'
testCases = require './test-cases'

translations =
  basic:
    pipeline: [
      $group:
        _id: '$category'
        count: $sum: 1
    , $sort: count: -1
    ]

  countAsc:
    pipeline: [
      $group:
        _id: '$category'
        count: $sum: 1
    , $sort: count: 1
    ]

  byValue:
    pipeline: [
      $group:
        _id: '$category'
        count: $sum: 1
    , $sort: _id: 1
    ]

  valueDesc:
    pipeline: [
      $group:
        _id: '$category'
        count: $sum: 1
    , $sort: _id: -1
    ]

translations.withLimit =
  pipeline: translations.basic.pipeline.concat [$limit: 100]
translations.withQuery =
  pipeline: [$match: difficulty: 'high'].concat translations.basic.pipeline


facetTester = common.makeTester testCases, components.toMongo, translations

describe 'Mongo facet query tests', () ->

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
