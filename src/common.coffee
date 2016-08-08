_ = require 'lodash'

TYPES =
  Q: 'Q'
  AND: 'AND'
  OR: 'OR'
  RAW: 'RAW'
  INSERT: 'INSERT'
  UPDATE: 'UPDATE'
  REMOVE: 'REMOVE'

ACTION_TYPES =
  QUERY: 'ACTION_QUERY'
  FACET: 'ACTION_FACET'
  INSERT: 'ACTION_INSERT'
  UPDATE: 'ACTION_UPDATE'
  REMOVE: 'ACTION_REMOVE'

ensureNumericValue = (obj, field) ->
  if obj[field]?
    val = parseInt obj[field]
    if isNaN val
      delete obj[field]
    else
      obj[field] = val
  return obj

canonicalizeOpts = (q) ->
  opts = q.options or {}
  # Ensure table is under options if it exists
  opts.table = q.table if q.table?
  if opts.columns?
    opts.fields = opts.columns
    delete opts.columns
  # Ensure offset and limit are numbers
  opts = ensureNumericValue opts, 'limit'
  opts = ensureNumericValue opts, 'offset'
  return opts

canonicalizeQuery = (q) ->
  query = switch
    when q.query? then q.query
    when q.filter? then q.filter
    when not isWrite(q) and not q.facet? then q
    else {}

isAscVal = (v) ->
  return switch v
    when 1, '1', 'asc', 'ascending' then true
    else false

isDescVal = (v) ->
  return switch v
    when -1, '-1', 'desc', 'descending' then true
    else false


isRaw = (q) ->
  TYPES.RAW is q.type

isRegularWrite = (q) ->
  switch q.type
    when TYPES.INSERT, TYPES.UPDATE, TYPES.REMOVE
      true
    else
      false

isRawWrite = (q) ->
  return false unless isRaw q
  switch q.action_type
    when ACTION_TYPES.INSERT, ACTION_TYPES.UPDATE, ACTION_TYPES.REMOVE
      true
    else
      false

isWrite = (q) ->
  isRegularWrite(q) or isRawWrite(q)

# classification specifies if it's the regular,
# raw or either type. Default is 'either'
validateClassification = (classification) ->
  return 'either' unless 'string' is typeof classification
  classification = classification.trim().toLowerCase()
  switch classification
    when 'regular', 'raw'
      classification
    else
      'either'

checkRegularType = (q, checkType) ->
  TYPES[checkType] is q.type

checkRawType = (q, checkType) ->
  (TYPES.RAW is q.type) and (ACTION_TYPES[checkType] is q.action_type)

commonCheckType = (q, checkType, classification = 'either') ->
  classification = validateClassification classification
  switch classification
    when 'regular'
      checkRegularType q, checkType
    when 'raw'
      checkRawType q, checkType
    when 'either'
      (checkRegularType q, checkType) or (checkRawType q, checkType)

isInsert = (q, classification = 'either') ->
  commonCheckType q, 'INSERT', classification

isUpdate = (q, classification = 'either') ->
  q.upsert isnt true and commonCheckType q, 'UPDATE', classification

isUpsert = (q, classification = 'either') ->
  q.upsert is true and commonCheckType q, 'UPDATE', classification

isRemove = (q, classification = 'either') ->
  commonCheckType q, 'REMOVE', classification


module.exports =
  TYPES: TYPES
  ACTION_TYPES: ACTION_TYPES

  preprocess: (q) ->
    q = _.cloneDeep q
    query = canonicalizeQuery q
    options = canonicalizeOpts q
    q.query = query
    q.options = options
    return q

  isRegularWrite: isRegularWrite
  isRawWrite: isRawWrite
  isWrite: isWrite
  isRaw: isRaw
  isInsert: isInsert
  isUpdate: isUpdate
  isUpsert: isUpsert
  isRemove: isRemove

  isAscVal: isAscVal
  isDescVal: isDescVal

  makeSortValueFormatter: (ascVal, descVal) ->
    return (v) ->
      if typeof v is 'string'
        v = v.toLowerCase()
      v = switch
        when isAscVal v then ascVal
        when isDescVal v then descVal
        else
          throw new Error 'Invalid field sort direction: ' + v
      return v

  # Ensure an input is a JSON object
  objectify: (input) ->
    if 'string' is typeof input
      try
        q = JSON.parse input
      catch e
        throw new Error "Failed to parse: #{input} -- #{e}"
    else if input instanceof Object
      q = input
    else
      throw new Error "Malformed input query: #{input}"
    return q

