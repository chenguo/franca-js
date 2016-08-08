require 'should'
testCases = require './test-cases'
common = require '../../common'
TYPES = require('../../../lib/common').TYPES
ACTION_TYPES = require('../../../lib/common').ACTION_TYPES
mongoWrite = require('../../../lib/components/write').toMongo


# Translations
translations =
  basicInsert: [testCases.basicInsert.write]
  multiInserts: testCases.multiInserts.write
  update: $set: testCases.update.write
  mongoUpsert: $set: testCases.mongoUpsert.write
  remove: undefined

rawWrites = [
  type: TYPES.RAW
  action_type: ACTION_TYPES.INSERT
  raw: [ testCases.simpleDoc1, testCases.simpleDoc2 ]
,
  type: TYPES.RAW
  action_type: ACTION_TYPES.UPDATE
  raw:
    query: testCases.simpleDoc1
    update: $set: testCases.updateDoc1
,
  type: TYPES.RAW
  action_type: ACTION_TYPES.REMOVE
  raw: testCases.simpleDoc1
]


testWrite = common.makeTester testCases, mongoWrite, translations


describe 'Mongo write tests', () ->

  it 'should translate a single insert', () ->
    testWrite 'basicInsert'

  it 'should translate a multi inserts', () ->
    testWrite 'multiInserts'

  it 'should translate an update', () ->
    testWrite 'update'

  it 'should translate an upsert', () ->
    testWrite 'mongoUpsert'

  it 'should translate a remove', () ->
    testWrite 'remove'

  for raw in rawWrites
    it "should not translate the #{raw.type} query", () ->
      translated = mongoWrite raw
      translated.should.be.eql raw.raw
