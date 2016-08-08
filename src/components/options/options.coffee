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

  multiRowOptions: () -> {}

  upsertOptions: () -> {}

  miscOptions: () -> {}

  convertOptions: (opts, q) =>
    opts = optsCommon.canonicalizeOptions opts
    arrOfOpts = [
      @rowOptions, @sortOptions, @fieldOptions, @tableOptions,
      @multiRowOptions, @upsertOptions, @miscOptions
    ].map (optFn) => optFn.call @, opts, q
    return _.merge.apply _, arrOfOpts

module.exports = BaseOptions
