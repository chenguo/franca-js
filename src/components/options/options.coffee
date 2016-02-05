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

  convertOptions: (opts) =>
    opts = optsCommon.canonicalizeOptions opts
    rowOpts = @rowOptions opts
    sortOpts = @sortOptions opts
    fieldOpts = @fieldOptions opts
    tableOpts = @tableOptions opts
    merged = _.merge rowOpts, sortOpts, fieldOpts, tableOpts
    return merged

module.exports = BaseOptions
