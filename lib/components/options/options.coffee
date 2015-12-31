_ = require 'lodash'
r = require('app-root-path').require
common = r('lib/common')

class BaseOptions

  constructor: () ->
    unless @ASC? and @DESC?
      throw new Error 'Sort order values not specified'
    @formatSortValue = common.makeSortValueFormatter @ASC, @DESC

  rowOptions: () -> {}
  sortOptions: () -> {}
  fieldOptions: () -> {}
  # Only used for SQL based translations
  tableOptions: () -> {}

  formatSortOpts: (opts) ->
    if opts.sort?
      if opts.sort instanceof Array
        orderings = opts.sort.map (s) =>
          [s[0], @formatSortValue s[1]]
      else if opts.sort instanceof Object
        orderings = _.map opts.sort, (v, k) =>
          [k, @formatSortValue v]
      else
        unless typeof opts.sort is 'string'
          msg = JSON.stringify opts.sort
        else
          msg = opts.sort
        throw new Error 'Invalid sort option format: ' + msg
      return orderings

  canonicalizeOptions: (opts) ->
    if opts.fields?
      if typeof opts.fields is 'string'
        opts.fields = [opts.fields]
      else if opts.fields not instanceof Array
        throw new Error 'Field specification must be string or array: ' + opts.fields
    return opts

  convertOptions: (opts) =>
    opts = @canonicalizeOptions opts
    rowOpts = @rowOptions opts
    sortOpts = @sortOptions opts
    fieldOpts = @fieldOptions opts
    tableOpts = @tableOptions opts
    merged = _.merge rowOpts, sortOpts, fieldOpts, tableOpts
    return merged

module.exports = BaseOptions
