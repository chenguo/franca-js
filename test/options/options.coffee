_ = require 'lodash'

offset = offset: 100
limit = limit: 10
sortArr = sort: [['name', -1], ['address', 1]]
sortObj =
  sort:
    name: 'Descending'
    address: 'asc'


module.exports =
  empty: {}
  offset: offset
  limit: limit
  sortArr: sortArr
  sortObj: sortObj
  combined: _.merge {}, offset, limit, sortArr
