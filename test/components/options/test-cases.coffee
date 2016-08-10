_ = require 'lodash'
TYPES = require('../../../lib/common').TYPES

limit = limit: 10
offset = offset: 100
fields = fields: ['volume', 'area', 'weight']
sortArr = sort: [['name', -1], ['address', 1]]
sortObj =
  sort:
    name: 'Descending'
    address: 'asc'
single = singleRow: true
multiple = singleRow: false

module.exports =
  empty: {}
  limit: limit
  offset: offset
  fields: fields
  sortArr: sortArr
  sortObj: sortObj
  combined: _.merge {}, offset, limit, fields, sortArr
  singleUpdate:
    type: TYPES.UPDATE
    query: {}
    write: {}
    options: single
  mongoMultipleUpsert:
    type: TYPES.UPDATE
    upsert: true
    query: {}
    write: {}
    options: multiple
  singleRemove:
    type: TYPES.REMOVE
    query: {}
    options: single
  multipleRemove:
    type: TYPES.REMOVE
    query: {}
    options: multiple
