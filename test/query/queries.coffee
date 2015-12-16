r = require('app-root-path').require
q = r('index').query

TYPES = q.TYPES

basic =
  type: TYPES.Q
  field: 'name'
  match: 'Bill'

typeless =
  field: 'location'
  match: 'Los Angeles'
  negate: true

multimatch =
  type: TYPES.Q
  field: 'name'
  match: ['Bill', 'Will']

nullQuery =
  type: TYPES.Q
  field: 'name'
  null: true

range =
  type: TYPES.Q
  field: 'age'
  range:
    min: 20
    max: 30

singleBoundRange =
  type: TYPES.Q
  field: 'age'
  range: min: 20

regexp =
  type: TYPES.Q
  field: 'name'
  regexp: '[wb]ill'
  regFlags: 'i'

compound =
  type: TYPES.AND
  queries: [
    singleBoundRange
  , typeless
  ]

nestedCompound =
  type: TYPES.OR
  queries: [
    basic
    compound
  ]


module.exports =
  basic: basic
  typeless: typeless
  multimatch: multimatch
  null: nullQuery
  range: range
  singleBoundRange: singleBoundRange
  regexp: regexp
  compound: compound
  nestedCompound: nestedCompound