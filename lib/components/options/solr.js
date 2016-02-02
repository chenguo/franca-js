(function() {
  var BaseOptions, SolrOptions,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BaseOptions = require('./options');

  SolrOptions = (function(superClass) {
    extend(SolrOptions, superClass);

    function SolrOptions() {
      this.sortOptions = bind(this.sortOptions, this);
      return SolrOptions.__super__.constructor.apply(this, arguments);
    }

    SolrOptions.prototype.ASC = 'asc';

    SolrOptions.prototype.DESC = 'desc';

    SolrOptions.prototype.rowOptions = function(opts) {
      var rowOpts;
      rowOpts = {};
      if (!isNaN(opts.offset)) {
        rowOpts.start = parseInt(opts.offset);
      }
      if (!isNaN(opts.limit)) {
        rowOpts.rows = parseInt(opts.limit);
      }
      return rowOpts;
    };

    SolrOptions.prototype.sortOptions = function(opts) {
      var orderings, sortStr, sorts;
      orderings = this.formatSortOpts(opts);
      if ((orderings != null) && orderings.length > 0) {
        sorts = orderings.map((function(_this) {
          return function(order) {
            return order[0] + '+' + order[1];
          };
        })(this));
        sortStr = sorts.join(',');
        return {
          sort: sortStr
        };
      }
    };

    SolrOptions.prototype.fieldOptions = function(opts) {
      if ((opts.fields != null) && opts.fields instanceof Array) {
        return {
          fl: opts.fields.join(',')
        };
      }
    };

    return SolrOptions;

  })(BaseOptions);

  module.exports = (new SolrOptions).convertOptions;

}).call(this);
