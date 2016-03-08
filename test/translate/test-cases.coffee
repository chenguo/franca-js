franca = require '../../index'
testTable = 'tab'

module.exports =

  testTable: testTable

  sampleQuery:
    options:
      offset: 50
      limit: 10
      table: testTable
    query:
      type: franca.TYPES.Q
      field: 'price'
      range: lte: 100

  compoundQuery:
    type: franca.TYPES.AND
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
    type: franca.TYPES.Q
    field: 'price'
    match: 100
