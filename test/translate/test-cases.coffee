franca = require '../../index'
testTable = 'tab'
TYPES = franca.TYPES

insertDoc = [
  field1: 'foo1'
  field2: 'bar1'
,
  field1: 'foo2'
  field2: 'bar2'
  field3: 'test3'
]

queryDoc1 =
  type: TYPES.AND
  queries: [
    field: 'field1'
    match: 'foo1'
  ,
    field: 'field2',
    match: 'bar1'
  ]

simplifiedQueryDoc1 =
  $and: [
    field1: 'foo1'
  ,
    field2: 'bar1'
  ]

updateDoc1 =
  field1: 'foo2'
  field2: 'bar2'
  field3: 'test3'

updateDoc2 =
  field2: 'bar1'
  field3: 'test3'
  field4: 'test4'

module.exports =

  testTable: testTable

  sampleQuery:
    options:
      offset: 50
      limit: 10
      table: testTable
    query:
      type: TYPES.Q
      field: 'price'
      range: lte: 100

  compoundQuery:
    type: TYPES.AND
    options:
      fields: ['brand', 'size']
      table: testTable
    queries: [
      field: 'type'
      match: 'pants'
    ,
      field: 'price'
      range: lte: 100
    ]

  sampleFacet:
    facet:
      field: 'city'
      sort: 'value'
    query:
      field: 'population'
      range: gte: 1000000
    table: testTable

  noTable:
    type: TYPES.Q
    field: 'price'
    match: 100

  simplifiedQueryDoc1: simplifiedQueryDoc1

  insertWrite:
    type: TYPES.INSERT
    write: insertDoc
    table: testTable

  updateWrite:
    type: TYPES.UPDATE
    query: queryDoc1
    write: updateDoc1
    options:
      table: testTable
      singleRow: true
      primaryField: 'id'

  mongoUpsertWrite:
    type: TYPES.UPDATE
    upsert: true
    query: queryDoc1
    write: updateDoc1
    options: table: testTable

  pgUpsertWrite:
    type: TYPES.UPDATE
    upsert: true
    query: queryDoc1
    write: updateDoc2
    options:
      table: testTable

  pgUpsertWriteInvalid:
    type: TYPES.UPDATE
    upsert: true
    query: queryDoc1
    write: updateDoc1
    options: table: testTable

  removeWrite:
    type: TYPES.REMOVE
    table: testTable
    query: queryDoc1
    options:
      singleRow: true
      primaryField: 'id'
