require 'should'
common = require '../common'
franca = require '../../index'
testCases = require './test-cases'
TYPES = require('../../lib/common').TYPES
ACTION_TYPES = require('../../lib/common').ACTION_TYPES

translations =
  sampleQuery: "SELECT * FROM #{testCases.testTable} WHERE price <= 100 LIMIT 10 OFFSET 50"
  compoundQuery: "SELECT brand, size FROM #{testCases.testTable} WHERE (type = 'pants' AND price <= 100)"
  sampleFacet: "SELECT city, COUNT(city) FROM #{testCases.testTable} WHERE population >= 1000000 GROUP BY city ORDER BY city ASC"
  insertWrite: "INSERT INTO #{testCases.testTable} (field1, field2, field3) VALUES ('foo1', 'bar1', null), ('foo2', 'bar2', 'test3')"
  updateWrite: "UPDATE #{testCases.testTable} SET field1 = 'foo2', field2 = 'bar2', field3 = 'test3' WHERE id = (SELECT id FROM #{testCases.testTable} WHERE (field1 = 'foo1' AND field2 = 'bar1') ORDER BY id ASC LIMIT 1)"
  pgUpsertWrite: "INSERT INTO #{testCases.testTable} (field1, field2, field3, field4) VALUES ('foo1', 'bar1', 'test3', 'test4') ON CONFLICT (field1, field2) DO UPDATE SET field3 = 'test3', field4 = 'test4'"
  removeWrite: "DELETE FROM #{testCases.testTable} WHERE id = (SELECT id FROM #{testCases.testTable} WHERE (field1 = 'foo1' AND field2 = 'bar1') ORDER BY id ASC LIMIT 1)"

rawInsertDoc = "INSERT INTO test-table (name, address) VALUES ('Bill', 'LA')"
rawUpdateDoc = "UPDATE test-table SET name='Bill', address='LA' WHERE id='001'"
rawRemoveDoc = "DELETE FROM test-table WHERE name='Bill', address='LA'"

rawTranslations = [
  query:
    type: TYPES.RAW
    action_type: ACTION_TYPES.INSERT
    raw: rawInsertDoc
  translate: rawInsertDoc
,
  query:
    type: TYPES.RAW
    action_type: ACTION_TYPES.UPDATE
    raw: rawUpdateDoc
  translate: rawUpdateDoc
,
  query:
    type: TYPES.RAW
    action_type: ACTION_TYPES.REMOVE
    raw: rawRemoveDoc
  translate: rawRemoveDoc
]

testFn = common.makeTester testCases, franca.toPg, translations

describe 'Postgres integration tests', () ->

  it 'translate a Postgres query', () ->
    testFn 'sampleQuery'

  it 'translate multiple Postgres queries', () ->
    testFn 'sampleQuery'
    testFn 'sampleQuery'

  it 'translate a compound Postgres query', () ->
    testFn 'compoundQuery'

  it 'translate a Postgres facet', () ->
    testFn 'sampleFacet'

  it 'throw error when no table given', () ->
    franca.toPg.bind(null, testCases.noTable).should.throw()

  it 'translate a raw Postgres query', () ->
    raw = 'select * from table'
    rawQuery =
      type: franca.TYPES.RAW
      raw: raw
    translated = franca.toPg rawQuery
    translated.should.be.eql raw

  it 'translate a raw Postgres query with options', () ->
    rawWhere = "price <= 100 AND type = 'pants'"
    rawQuery =
      type: franca.TYPES.RAW
      raw: rawWhere
      options:
        table: testCases.testTable
    translated = franca.toPg rawQuery
    translated.should.be.eql "SELECT * FROM #{testCases.testTable} WHERE #{rawWhere}"

  it 'translate a Postgres insert', () ->
    testFn 'insertWrite'

  it 'translate a Postgres update', () ->
    testFn 'updateWrite'

  it 'translate a Postgres upsert', () ->
    testFn 'pgUpsertWrite'

  it 'should throw error when query and update collided for Pg upsert', () ->
    franca.toPg.bind(null, testCases.pgUpsertWriteInvalid).should.throw()

  it 'translate a Postgres remove', () ->
    testFn 'removeWrite'

  for raw in rawTranslations
    it "translate a Postgres raw #{raw.query.type}", () ->
      translated = franca.toPg raw.query
      translated.should.be.eql raw.translate
