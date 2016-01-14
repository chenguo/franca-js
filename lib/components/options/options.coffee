_ = require 'lodash'
common = require '../../common'
optsCommon = require './common'

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

  formatSortOpts: (opts) =>
    return optsCommon.getSorts opts, @formatSortValue

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
