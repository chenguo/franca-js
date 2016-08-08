require 'should'
testCases = require './test-cases'
common = require '../../common'
TYPES = require('../../../lib/common').TYPES
ACTION_TYPES = require('../../../lib/common').ACTION_TYPES
pgWrite = require('../../../lib/components/write').toPg


# Translations
translations =
  basicInsert: "(name, address) VALUES ('Bill', 'LA')"
  multiInserts: "(name, address, country) VALUES ('Bill', 'LA', null), ('Jack', 'NY', 'US')"
  update: "address = 'NY', country = 'US'"
  pgUpsert:
    insert: "(name, address, country) VALUES ('Bill', 'NY', 'US')"
    conflict: "(name, address)"
    update: "country = 'US'"
  remove: ""

rawWrites = [
  type: TYPES.RAW
  action_type: ACTION_TYPES.INSERT
  raw: "INSERT INTO test-table (name, address) VALUES ('Bill', 'LA')"
,
  type: TYPES.RAW
  action_type: ACTION_TYPES.UPDATE
  raw: "UPDATE test-table SET name='Bill', address='LA' WHERE id='001'"
,
  type: TYPES.RAW
  action_type: ACTION_TYPES.REMOVE
  raw: "DELETE FROM test-table WHERE name='Bill', address='LA'"
]

testWrite = common.makeTester testCases, pgWrite, translations


describe 'Postgres write tests', () ->

  it 'should translate a single insert', () ->
    testWrite 'basicInsert'

  it 'should translate a multiple inserts', () ->
    testWrite 'multiInserts'

  it 'should translate an update', () ->
    testWrite 'update'

  it 'should translate an upsert', () ->
    testWrite 'pgUpsert'

  it 'should throw error when query and update collided for Pg upsert', () ->
    pgWrite.bind(null, testCases.pgUpsertInvalid).should.throw()

  it 'should translate an remove', () ->
    testWrite 'remove'

  for raw in rawWrites
    it "should not translate the #{raw.type} query", () ->
      translated = pgWrite raw
      translated.should.be.eql raw.raw
