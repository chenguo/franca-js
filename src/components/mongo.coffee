_ = require 'lodash'
common = require '../common'
mongoFacet = require('./facet').toMongo
mongoQuery = require('./query').toMongo
mongoWrite = require('./write').toMongo
mongoOptions = require('./options').toMongo

processOptAndQuery = (q, components = {}) ->
  components.options = mongoOptions q.options, q
  components.query = mongoQuery q.query
  return components

processFacetOrWrite = (q, components = {}) ->
  if common.isRemove q, 'regular'
    components.remove = components.query
    delete components.query
  else if common.isWrite q
    writes = mongoWrite q
    components[getWriteCompField q] = writes
    if common.isUpsert q, 'raw'
      components = _.merge components, components.update
  else if q.facet?
    components = pipeline: mongoFacet components, q.facet
  return components

getWriteCompField = (q) ->
  if common.isInsert q then 'insert'
  else if common.isUpdate(q) or common.isUpsert(q) then 'update'
  else if common.isRemove q then 'remove'
  else
    throw new Error "Invalid Write Type: #{q.type}"


module.exports = (q) ->
  q = common.preprocess q
  components = processOptAndQuery q
  collection = components.options.collection
  delete components.options.collection
  components = processFacetOrWrite q, components
  components.collection = collection if collection?
  return _.pick components, (v, k) -> not _.isEmpty v
