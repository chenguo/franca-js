common = require '../common'
franca = require '../../index'
testCases = require './test-cases'
TYPES = require('../../lib/common').TYPES
ACTION_TYPES = require('../../lib/common').ACTION_TYPES

translations =
  sampleQuery:
    collection: testCases.testTable
    query:
      price: $lte: 100
    options:
      skip: 50
      limit: 10

  sampleFacet:
    collection: testCases.testTable
    pipeline: [
      $match:
        population: $gte: 1000000
    ,
      $group:
        _id: '$city'
        count: $sum: 1
    ,
      $sort: _id: 1
    ]

  insertWrite:
    collection: testCases.testTable
    insert: testCases.insertWrite.write

  updateWrite:
    collection: testCases.testTable
    query: testCases.simplifiedQueryDoc1
    update: $set: testCases.updateWrite.write
    options: multi: false

  mongoUpsertWrite:
    collection: testCases.testTable
    query: testCases.simplifiedQueryDoc1
    update: $set: testCases.mongoUpsertWrite.write
    options:
      upsert: true
      multi: true

  removeWrite:
    collection: testCases.testTable
    remove: testCases.simplifiedQueryDoc1
    options: justOne: true

rawInsertDoc = [
  name: 'Bill'
  address: 'LA'
,
  name: 'Jack'
  address: 'NY'
  country: 'US'
]

rawQueryDoc =
  name: 'Bill'
  address: 'LA'

rawUpdateDoc =
  $set:
    address: 'NY'
    country: 'US'

rawTranslations = [
  query:
    type: TYPES.RAW
    action_type: ACTION_TYPES.INSERT
    raw: rawInsertDoc
  translate:
    insert: rawInsertDoc
,
  query:
    type: TYPES.RAW
    action_type: ACTION_TYPES.UPDATE
    raw: query: rawQueryDoc, update: rawUpdateDoc
  translate:
    query: rawQueryDoc
    update: rawUpdateDoc
,
  query:
    type: TYPES.RAW
    action_type: ACTION_TYPES.UPDATE
    upsert: true
    raw: query: rawQueryDoc, update: rawUpdateDoc
  translate:
    query: rawQueryDoc
    update: rawUpdateDoc
    options: upsert: true
,
  query:
    type: TYPES.RAW
    action_type: ACTION_TYPES.REMOVE
    raw: rawQueryDoc
  translate:
    remove: rawQueryDoc
    options: justOne: false
]

testFn = common.makeTester testCases, franca.toMongo, translations

describe 'Mongo integration tests', () ->

  it 'translate a Mongo query', () ->
    testFn 'sampleQuery'

  it 'translate multiple Mongo queries', () ->
    testFn 'sampleQuery'
    testFn 'sampleQuery'

  it 'translate a Mongo facet', () ->
    testFn 'sampleFacet'

  it 'translate a Mongo insert', () ->
    testFn 'insertWrite'

  it 'translate a Mongo update', () ->
    testFn 'updateWrite'

  it 'translate a Mongo upsert', () ->
    testFn 'mongoUpsertWrite'

  it 'translate a Mongo remove', () ->
    testFn 'removeWrite'

  for raw in rawTranslations
    it "translate a Mongo raw #{raw.query.type}", () ->
      translated = franca.toMongo raw.query
      translated.should.be.eql raw.translate
