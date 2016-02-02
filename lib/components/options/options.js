(function() {
  var BaseOptions, _, common, optsCommon,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require('lodash');

  common = require('../../common');

  optsCommon = require('./common');

  BaseOptions = (function() {
    function BaseOptions() {
      this.convertOptions = bind(this.convertOptions, this);
      this.formatSortOpts = bind(this.formatSortOpts, this);
      if (!((this.ASC != null) && (this.DESC != null))) {
        throw new Error('Sort order values not specified');
      }
      this.formatSortValue = common.makeSortValueFormatter(this.ASC, this.DESC);
    }

    BaseOptions.prototype.rowOptions = function() {
      return {};
    };

    BaseOptions.prototype.sortOptions = function() {
      return {};
    };

    BaseOptions.prototype.fieldOptions = function() {
      return {};
    };

    BaseOptions.prototype.tableOptions = function() {
      return {};
    };

    BaseOptions.prototype.formatSortOpts = function(opts) {
      return optsCommon.getSorts(opts, this.formatSortValue);
    };

    BaseOptions.prototype.canonicalizeOptions = function(opts) {
      if (opts.fields != null) {
        if (typeof opts.fields === 'string') {
          opts.fields = [opts.fields];
        } else if (!(opts.fields instanceof Array)) {
          throw new Error('Field specification must be string or array: ' + opts.fields);
        }
      }
      return opts;
    };

    BaseOptions.prototype.convertOptions = function(opts) {
      var fieldOpts, merged, rowOpts, sortOpts, tableOpts;
      opts = this.canonicalizeOptions(opts);
      rowOpts = this.rowOptions(opts);
      sortOpts = this.sortOptions(opts);
      fieldOpts = this.fieldOptions(opts);
      tableOpts = this.tableOptions(opts);
      merged = _.merge(rowOpts, sortOpts, fieldOpts, tableOpts);
      return merged;
    };

    return BaseOptions;

  })();

  module.exports = BaseOptions;

}).call(this);
