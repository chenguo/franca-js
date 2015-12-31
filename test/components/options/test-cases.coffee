_ = require 'lodash'

limit = limit: 10
offset = offset: 100
fields = fields: ['volume', 'area', 'weight']
sortArr = sort: [['name', -1], ['address', 1]]
sortObj =
  sort:
    name: 'Descending'
    address: 'asc'

module.exports =
  empty: {}
  limit: limit
  offset: offset
  fields: fields
  sortArr: sortArr
  sortObj: sortObj
  combined: _.merge {}, offset, limit, fields, sortArr
