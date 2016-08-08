common = require '../../../lib/common'
TYPES = common.TYPES

simpleDoc1 =
  name: 'Bill'
  address: 'LA'

queryDoc1 =
  type: TYPES.AND
  queries: [
    field: 'name'
    match: 'Bill'
  ,
    field: 'address'
    match: 'LA'
  ]

updateDoc1 =
  address: 'NY'
  country: 'US'

simpleDoc2 =
  name: 'Jack'
  address: 'NY'
  country: 'US'

queryDoc2 =
  type: TYPES.AND
  queries: [
    field: 'name'
    match: 'Bill'
  ,
    field: 'address'
    match: 'NY'
  ]


module.exports =
  simpleDoc1: simpleDoc1
  queryDoc1: queryDoc1
  updateDoc1: updateDoc1
  simpleDoc2: simpleDoc2
  queryDoc2: queryDoc2

  basicInsert:
    type: TYPES.INSERT
    write: simpleDoc1

  multiInserts:
    type: TYPES.INSERT
    write: [ simpleDoc1, simpleDoc2 ]

  update:
    type: TYPES.UPDATE
    query: queryDoc1
    write: updateDoc1

  mongoUpsert:
    type: TYPES.UPDATE
    upsert: true
    query: queryDoc1
    write: updateDoc1

  pgUpsert:
    type: TYPES.UPDATE
    upsert: true
    write:
      query: queryDoc2
      update: updateDoc1

  pgUpsertInvalid:
    type: TYPES.UPDATE
    upsert: true
    write:
      query: queryDoc1
      update: updateDoc1

  remove:
    type: TYPES.REMOVE
    query: queryDoc1
